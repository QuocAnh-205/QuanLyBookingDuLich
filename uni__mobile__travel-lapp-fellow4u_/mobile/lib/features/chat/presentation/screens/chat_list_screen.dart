import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../provider/chat_provider.dart';
import '../widgets/chat_tile.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        final provider = context.read<ChatProvider>();
        provider.fetchRooms(auth.token!);
        provider.startPolling(auth.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildSearchBox(),
          ),
          _buildChatList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF00CEA6),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          'Chat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://skyticket.com/guide/wp-content/uploads/2017/12/iStock-502607495-e1534733959975.jpg', // Danang Bridge or Seoul
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.grey, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search Chat',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.rooms.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: Color(0xFF00CEA6))),
          );
        }

        if (provider.error != null && provider.rooms.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${provider.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        final auth = context.read<AuthProvider>();
                        if (auth.token != null) provider.fetchRooms(auth.token!);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00CEA6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (provider.rooms.isEmpty) {
          return SliverFillRemaining(child: _buildEmptyState());
        }

        return SliverPadding(
          padding: const EdgeInsets.only(bottom: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ChatTile(room: provider.rooms[index]);
              },
              childCount: provider.rooms.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text(
            'No messages yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a conversation with your guide!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Stop background polling when leaving chat feature
    context.read<ChatProvider>().stopPolling();
    super.dispose();
  }
}
