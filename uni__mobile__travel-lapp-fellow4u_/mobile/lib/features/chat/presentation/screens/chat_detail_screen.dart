import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/chat_models.dart';
import '../provider/chat_provider.dart';
import '../widgets/message_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final int roomId;

  const ChatDetailScreen({super.key, required this.roomId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
    });
  }

  void _loadMessages() {
    final auth = context.read<AuthProvider>();
    if (auth.token != null) {
      final provider = context.read<ChatProvider>();
      provider.fetchMessages(widget.roomId, auth.token!).then((_) {
        _scrollToBottom();
      });
      // Start real-time polling
      provider.startPolling(auth.token!, roomId: widget.roomId);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final auth = context.read<AuthProvider>();
    if (auth.token != null && auth.userId != null) {
      context.read<ChatProvider>().sendMessage(widget.roomId, content, auth.token!, auth.userId!);
      _messageController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        final room = provider.rooms.firstWhere((r) => r.id == widget.roomId);
        final currentUserId = context.read<AuthProvider>().userId;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(room),
          body: Column(
            children: [
              Expanded(
                child: provider.isLoading && provider.messages.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF00CEA6)))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        itemCount: provider.messages.length,
                        itemBuilder: (context, index) {
                          final message = provider.messages[index];
                          return MessageBubble(
                            message: message,
                            isMe: message.senderId == currentUserId,
                          );
                        },
                      ),
              ),
              _buildInputArea(),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ChatRoom room) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: room.otherParticipant.avatarUrl.isNotEmpty
                ? NetworkImage(room.otherParticipant.avatarUrl)
                : null,
            child: room.otherParticipant.avatarUrl.isEmpty
                ? const Icon(Icons.person, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${room.otherParticipant.name} ${room.bookingId != null ? "(Booking #${room.bookingId})" : ""}',
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Online',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.call_outlined, color: Color(0xFF00CEA6)), onPressed: () {}),
        IconButton(icon: const Icon(Icons.videocam_outlined, color: Color(0xFF00CEA6)), onPressed: () {}),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF00CEA6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _handleSend,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Stop polling when leaving chat room
    // The provider might still be polling for rooms in background, 
    // we should switch it back to background polling.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
         final auth = context.read<AuthProvider>();
         if (auth.token != null) {
           context.read<ChatProvider>().startPolling(auth.token!);
         }
      }
    });
    super.dispose();
  }
}
