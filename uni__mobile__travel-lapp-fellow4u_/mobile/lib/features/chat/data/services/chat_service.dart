import 'package:dio/dio.dart';
import 'package:mobile/core/network/api_client.dart';

class ChatService {
  final Dio _dio = ApiClient.dio;

  Future<List<dynamic>> fetchChatRooms(String token) async {
    try {
      final response = await _dio.get(
        'chats',
        options: ApiClient.getOptionsWithToken(token),
      );
      
      if (response.data['success']) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch chat rooms');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> fetchMessages(int roomId, String token) async {
    try {
      final response = await _dio.get(
        'chats/$roomId',
        options: ApiClient.getOptionsWithToken(token),
      );
      
      if (response.data['success']) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch messages');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendMessage(int roomId, String content, String token, {String type = 'text'}) async {
    try {
      final response = await _dio.post(
        'chats/$roomId/messages',
        data: {
          'content': content,
          'message_type': type,
        },
        options: ApiClient.getOptionsWithToken(token),
      );
      
      if (response.data['success']) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Failed to send message');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(int roomId, String token) async {
    try {
      await _dio.put(
        'chats/$roomId/read',
        options: ApiClient.getOptionsWithToken(token),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> initChat(int bookingId, String token) async {
    try {
      final response = await _dio.post(
        'chats/init',
        data: {'booking_id': bookingId},
        options: ApiClient.getOptionsWithToken(token),
      );
      
      if (response.data['success']) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Failed to initialize chat');
    } catch (e) {
      rethrow;
    }
  }
}
