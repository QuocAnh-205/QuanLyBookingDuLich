import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class NotificationService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> fetchNotifications(String token, {int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        'notifications',
        queryParameters: {'page': page, 'limit': limit},
        options: ApiClient.getOptionsWithToken(token),
      );
      
      if (response.data['success']) {
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch notifications');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(int notifId, String token) async {
    try {
      await _dio.put(
        'notifications/$notifId/read',
        options: ApiClient.getOptionsWithToken(token),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead(String token) async {
    try {
      await _dio.put(
        'notifications/read-all',
        options: ApiClient.getOptionsWithToken(token),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotification(int notifId, String token) async {
    try {
      await _dio.delete(
        'notifications/$notifId',
        options: ApiClient.getOptionsWithToken(token),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadCount(String token) async {
    try {
      final response = await _dio.get(
        'notifications/unread-count',
        options: ApiClient.getOptionsWithToken(token),
      );
      if (response.data['success']) {
        return response.data['unread_count'];
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
