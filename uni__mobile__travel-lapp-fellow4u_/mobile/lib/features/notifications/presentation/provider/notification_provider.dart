import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';

enum NotificationFilter { all, unread, bookings, messages }

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  NotificationFilter _currentFilter = NotificationFilter.all;
  
  Timer? _pollingTimer;

  List<NotificationModel> get notifications {
    switch (_currentFilter) {
      case NotificationFilter.unread:
        return _notifications.where((n) => !n.isRead).toList();
      case NotificationFilter.bookings:
        return _notifications.where((n) => n.category == 'booking_update').toList();
      case NotificationFilter.messages:
        return _notifications.where((n) => n.category == 'chat_arrival').toList();
      default:
        return _notifications;
    }
  }
  
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  NotificationFilter get currentFilter => _currentFilter;

  void setFilter(NotificationFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void startPolling(String token) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _refreshUnreadCountAndList(token);
    });
    // Initial fetch
    _refreshUnreadCountAndList(token);
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _refreshUnreadCountAndList(String token) async {
    try {
      // Just update unread count for badge
      final newCount = await _service.getUnreadCount(token);
      if (newCount != _unreadCount) {
        _unreadCount = newCount;
        // If count changed, also refresh the list in background
        final response = await _service.fetchNotifications(token);
        final List<dynamic> data = response['data'];
        final List<NotificationModel> fetchedNotifs = data.map((json) => NotificationModel.fromJson(json)).toList();
        
        // Safety Deduplication (Fingerprint: category + relatedEntityId)
        final Map<String, NotificationModel> uniqueNotifs = {};
        for (var n in fetchedNotifs) {
          // If no entity ID (like promotions), use message as part of key
          final key = '${n.category}_${n.relatedEntityId ?? n.message.hashCode}';
          if (!uniqueNotifs.containsKey(key) || n.createdAt.isAfter(uniqueNotifs[key]!.createdAt)) {
            uniqueNotifs[key] = n;
          }
        }
        _notifications = uniqueNotifs.values.toList();
        _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      }
    } catch (e) {
      // Silently fail in background polling
    }
  }

  Future<void> fetchNotifications(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.fetchNotifications(token);
      final List<dynamic> data = response['data'];
      final List<NotificationModel> fetchedNotifs = data.map((json) => NotificationModel.fromJson(json)).toList();

      // Safety Deduplication (Fingerprint: category + relatedEntityId)
      final Map<String, NotificationModel> uniqueNotifs = {};
      for (var n in fetchedNotifs) {
        final key = '${n.category}_${n.relatedEntityId ?? n.message.hashCode}';
        if (!uniqueNotifs.containsKey(key) || n.createdAt.isAfter(uniqueNotifs[key]!.createdAt)) {
          uniqueNotifs[key] = n;
        }
      }
      _notifications = uniqueNotifs.values.toList();
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _unreadCount = await _service.getUnreadCount(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notifId, String token) async {
    try {
      final index = _notifications.indexWhere((n) => n.notifId == notifId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = NotificationModel(
          notifId: _notifications[index].notifId,
          userId: _notifications[index].userId,
          category: _notifications[index].category,
          title: _notifications[index].title,
          message: _notifications[index].message,
          relatedEntityType: _notifications[index].relatedEntityType,
          relatedEntityId: _notifications[index].relatedEntityId,
          isRead: true,
          readAt: DateTime.now(),
          extraData: _notifications[index].extraData,
          createdAt: _notifications[index].createdAt,
        );
        _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
        notifyListeners();
      }

      await _service.markAsRead(notifId, token);
    } catch (e) {
      // Rollback logic
    }
  }

  Future<void> markAllAsRead(String token) async {
    try {
      _notifications = _notifications.map((n) {
        if (!n.isRead) {
          return NotificationModel(
            notifId: n.notifId,
            userId: n.userId,
            category: n.category,
            title: n.title,
            message: n.message,
            relatedEntityType: n.relatedEntityType,
            relatedEntityId: n.relatedEntityId,
            isRead: true,
            readAt: DateTime.now(),
            extraData: n.extraData,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      _unreadCount = 0;
      notifyListeners();

      await _service.markAllAsRead(token);
    } catch (e) {
      // Rollback
    }
  }

  Future<void> deleteNotification(int notifId, String token) async {
    try {
      final index = _notifications.indexWhere((n) => n.notifId == notifId);
      if (index != -1) {
        final bool wasUnread = !_notifications[index].isRead;
        _notifications.removeAt(index);
        if (wasUnread) {
          _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
        }
        notifyListeners();
      }

      await _service.deleteNotification(notifId, token);
    } catch (e) {
      // Rollback
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
