import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/chat_models.dart';
import '../screens/chat_detail_screen.dart';

class ChatTile extends StatelessWidget {
  final ChatRoom room;

  const ChatTile({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(roomId: room.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${room.otherParticipant.name} ${room.bookingId != null ? "(Booking #${room.bookingId})" : ""}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _formatTime(room.lastMessageAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.lastMessagePreview ?? 'No messages yet',
                          style: TextStyle(
                            color: room.unreadCount > 0 ? Colors.black54 : Colors.grey[600],
                            fontSize: 15,
                            fontWeight: room.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (room.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            room.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: room.otherParticipant.avatarUrl.isNotEmpty
              ? NetworkImage(room.otherParticipant.avatarUrl)
              : null,
          backgroundColor: Colors.grey[200],
          child: room.otherParticipant.avatarUrl.isEmpty
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
        // Active indicator (Optional, based on design)
        Positioned(
          right: 0,
          bottom: 2,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat.Hm().format(date);
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(date);
    } else {
      return DateFormat.MMMd().format(date);
    }
  }
}
