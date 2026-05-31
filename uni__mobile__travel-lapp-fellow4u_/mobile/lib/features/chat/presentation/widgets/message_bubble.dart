import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/chat_models.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) _buildAvatar(),
              const SizedBox(width: 8),
              _buildContent(context),
            ],
          ),
          const SizedBox(height: 2),
          _buildTimestamp(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 12,
      backgroundColor: Colors.grey[300],
      child: const Icon(Icons.person, size: 14, color: Colors.white),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF00CEA6) : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: EdgeInsets.only(left: isMe ? 0 : 32, right: isMe ? 8 : 0),
      child: Text(
        DateFormat.Hm().format(message.createdAt),
        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
      ),
    );
  }
}
