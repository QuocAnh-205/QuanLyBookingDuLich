import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/notification_provider.dart';
import '../../data/models/notification_model.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/trips/presentation/screens/trip_detail_screen.dart';
import 'package:mobile/features/chat/presentation/screens/chat_detail_screen.dart';
import 'package:mobile/features/details/presentation/screens/tour_detail_screen.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<NotificationProvider>().fetchNotifications(token);
      }
    });
  }

  // ─── Navigation logic theo category & relatedEntityType ───────────────────
  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
    String token,
  ) {
    // 1. Đánh dấu đã đọc (optimistic update + API)
    if (!notification.isRead) {
      context.read<NotificationProvider>().markAsRead(notification.notifId, token);
    }

    // 2. Điều hướng đến màn hình liên quan
    final entityType = notification.relatedEntityType?.toLowerCase();
    final entityId = notification.relatedEntityId;
    final category = notification.category.toLowerCase();

    if (entityId == null) return; // không có entityId thì không navigate

    if (category == 'chat_arrival' || entityType == 'chat_room') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(roomId: entityId),
        ),
      );
    } else if (entityType == 'booking' ||
        category == 'booking_update' ||
        category == 'payment_status' ||
        category == 'review_reminder') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TripDetailScreen(tripId: entityId),
        ),
      );
    } else if (entityType == 'tour') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TourDetailScreen(tourId: entityId),
        ),
      );
    }
    // category == 'system_alert' hoặc không rõ → không navigate
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications;
    final token = context.read<AuthProvider>().token ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Banner Header ──────────────────────────────────────────────────
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://storage.mistudio.asia/ha-noi-viptour-9671112913/storage/cau-rong-da-nang-citytour-hanpiviptours.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
              const Positioned(
                bottom: 24,
                left: 24,
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Nút "Mark all read"
              if (notificationProvider.unreadCount > 0)
                Positioned(
                  bottom: 24,
                  right: 16,
                  child: TextButton(
                    onPressed: () =>
                        notificationProvider.markAllAsRead(token),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Mark all read',
                        style: TextStyle(fontSize: 13)),
                  ),
                ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ],
          ),

          // ── Notification List ──────────────────────────────────────────────
          Expanded(
            child: notificationProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : notifications.isEmpty
                    ? const Center(child: Text('No notifications'))
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final n = notifications[index];
                          return _NotificationItem(
                            notification: n,
                            onTap: () =>
                                _handleNotificationTap(context, n, token),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Item Widget ──────────────────────────────────────────────────────────────
class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');
    final category = notification.category.toLowerCase();
    final isRead = notification.isRead;

    // Sub-icon theo category
    IconData subIcon;
    Color subIconColor;
    if (category.contains('chat')) {
      subIcon = Icons.chat_bubble;
      subIconColor = const Color(0xFF00CEA6);
    } else if (category.contains('payment')) {
      subIcon = Icons.account_balance_wallet;
      subIconColor = Colors.orange;
    } else if (category.contains('review')) {
      subIcon = Icons.star;
      subIconColor = Colors.purple;
    } else if (category.contains('booking')) {
      subIcon = Icons.calendar_today;
      subIconColor = Colors.blue;
    } else {
      subIcon = Icons.info;
      subIconColor = Colors.grey;
    }

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Gộp color vào decoration để tránh conflict
          color: isRead
              ? Colors.white
              : const Color(0xFF00CEA6).withOpacity(0.07),
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
            // Viền trái xanh nếu chưa đọc
            left: isRead
                ? BorderSide.none
                : const BorderSide(
                    color: Color(0xFF00CEA6), width: 3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + sub-icon
            Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    notification.extraData?['sender_avatar'] ??
                        'https://via.placeholder.com/150',
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: subIconColor,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white, width: 2),
                    ),
                    child:
                        Icon(subIcon, color: Colors.white, size: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isRead
                          ? FontWeight.w400
                          : FontWeight.bold, // bold nếu chưa đọc
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Message
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Date
                  Text(
                    dateFormat.format(notification.createdAt),
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                  // Nút Leave Review nếu là review_reminder
                  if (category.contains('review')) ...[
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00CEA6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                      ),
                      child: const Text('Leave Review'),
                    ),
                  ],
                ],
              ),
            ),

            // Chấm tròn chưa đọc
            if (!isRead)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
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
}