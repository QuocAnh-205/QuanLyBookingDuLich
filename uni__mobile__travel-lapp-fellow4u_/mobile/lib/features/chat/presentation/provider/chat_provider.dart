import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/chat_models.dart';
import '../../data/services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  List<ChatRoom> _rooms = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  ChatRoom? _selectedRoom;
  Timer? _pollingTimer;

  List<ChatRoom> get rooms => _rooms;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ChatRoom? get selectedRoom => _selectedRoom;

  void startPolling(String token, {int? roomId}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      Duration(seconds: roomId != null ? 3 : 30),
      (_) {
        if (roomId != null) {
          _pollMessages(roomId, token);
        } else {
          fetchRooms(token);
        }
      },
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _pollMessages(int roomId, String token) async {
    try {
      final data = await _chatService.fetchMessages(roomId, token);
      final newMessages = data.map((json) => ChatMessage.fromJson(json)).toList();
      
      bool hasChanges = false;
      for (var msg in newMessages) {
        // Fingerprint: sender + content + timestamp (rounded to minute to catch SEED duplicates)
        final timeKey = msg.createdAt.millisecondsSinceEpoch ~/ 60000;
        final fingerprint = '${msg.senderId}_${msg.content}_$timeKey';
        
        if (!_messages.any((m) {
          final mTimeKey = m.createdAt.millisecondsSinceEpoch ~/ 60000;
          return '${m.senderId}_${m.content}_$mTimeKey' == fingerprint;
        })) {
          _messages.add(msg);
          hasChanges = true;
        }
      }
      
      if (hasChanges) {
        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Polling error: $e');
    }
  }

  Future<void> fetchRooms(String token) async {
    if (_rooms.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    
    try {
      final data = await _chatService.fetchChatRooms(token);
      final List<ChatRoom> fetchedRooms = data.map((json) => ChatRoom.fromJson(json)).toList();
      
      // Safety Deduplication (By room.id)
      final Map<int, ChatRoom> uniqueRooms = {};
      for (var room in fetchedRooms) {
        uniqueRooms[room.id] = room;
      }
      _rooms = uniqueRooms.values.toList();
      _rooms.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(int roomId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final data = await _chatService.fetchMessages(roomId, token);
      final List<ChatMessage> fetchedMessages = data.map((json) => ChatMessage.fromJson(json)).toList();

      // Deduplicate by content fingerprint (1-minute window)
      final Map<String, ChatMessage> uniqueMessages = {};
      for (var msg in fetchedMessages) {
        final timeKey = msg.createdAt.millisecondsSinceEpoch ~/ 60000;
        final fingerprint = '${msg.senderId}_${msg.content}_$timeKey';
        uniqueMessages[fingerprint] = msg;
      }
      
      _messages = uniqueMessages.values.toList();
      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      await _chatService.markAsRead(roomId, token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(int roomId, String content, String token, int currentUserId) async {
    // Optimistic Update
    final tempId = DateTime.now().millisecondsSinceEpoch * -1;
    final optimisticMessage = ChatMessage(
      id: tempId,
      roomId: roomId,
      senderId: currentUserId,
      content: content,
      type: ChatMessageType.text,
      isRead: false,
      createdAt: DateTime.now(),
    );
    
    _messages.add(optimisticMessage);
    notifyListeners();

    try {
      final data = await _chatService.sendMessage(roomId, content, token);
      final actualMessage = ChatMessage.fromJson(data);
      
      final index = _messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        _messages[index] = actualMessage;
      }
      
      _updateRoomPreview(roomId, content);
      
      notifyListeners();
    } catch (e) {
      _messages.removeWhere((m) => m.id == tempId);
      _error = e.toString();
      notifyListeners();
    }
  }

  void _updateRoomPreview(int roomId, String preview) {
    final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex != -1) {
      final room = _rooms[roomIndex];
      _rooms[roomIndex] = ChatRoom(
        id: room.id,
        bookingId: room.bookingId,
        lastMessagePreview: preview,
        lastMessageAt: DateTime.now(),
        otherParticipant: room.otherParticipant,
        unreadCount: room.unreadCount,
      );
      final updatedRoom = _rooms.removeAt(roomIndex);
      _rooms.insert(0, updatedRoom);
    }
  }

  Future<ChatRoom?> startChat(int bookingId, String token) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final data = await _chatService.initChat(bookingId, token);
      final room = ChatRoom.fromJson(data);
      
      if (!_rooms.any((r) => r.id == room.id)) {
        _rooms.insert(0, room);
      }
      
      _selectedRoom = room;
      return room;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectRoom(ChatRoom room) {
    _selectedRoom = room;
    _messages = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
