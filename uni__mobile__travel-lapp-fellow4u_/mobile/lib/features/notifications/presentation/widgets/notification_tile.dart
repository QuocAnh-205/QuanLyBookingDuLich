import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead ? Colors.transparent : const Color(0xFF00CEA6).withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(notification.createdAt),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(left: 12, top: 4),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF00CEA6),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    IconData iconData;
    Color iconColor;

    switch (notification.category) {
      case 'booking_update':
        iconData = Icons.calendar_today_outlined;
        iconColor = Colors.blue;
        break;
      case 'payment_status':
        iconData = Icons.account_balance_wallet_outlined;
        iconColor = Colors.orange;
        break;
      case 'chat_arrival':
        iconData = Icons.chat_bubble_outline;
        iconColor = const Color(0xFF00CEA6);
        break;
      case 'review_reminder':
        iconData = Icons.star_outline;
        iconColor = Colors.purple;
        break;
      case 'system_alert':
        iconData = Icons.info_outline;
        iconColor = Colors.redAccent;
        break;
      default:
        iconData = Icons.notifications_none;
        iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(date);
    } else {
      return DateFormat.MMMd().format(date);
    }
  }
}
