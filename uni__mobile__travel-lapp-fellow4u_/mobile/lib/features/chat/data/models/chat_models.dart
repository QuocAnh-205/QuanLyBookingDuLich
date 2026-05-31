enum ChatMessageType {
  text,
  image,
  location
}

class ChatParticipant {
  final int id;
  final String name;
  final String avatarUrl;

  ChatParticipant({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['user_id'],
      name: '${json['first_name']} ${json['last_name']}',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }
}

class ChatMessage {
  final int id;
  final int roomId;
  final int senderId;
  final String content;
  final ChatMessageType type;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['message_id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      content: json['content'],
      type: ChatMessageType.values.firstWhere(
        (e) => e.name == (json['message_type'] ?? 'text'),
        orElse: () => ChatMessageType.text,
      ),
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ChatRoom {
  final int id;
  final int? bookingId;
  final String? lastMessagePreview;
  final DateTime lastMessageAt;
  final ChatParticipant otherParticipant;
  final int unreadCount;

  ChatRoom({
    required this.id,
    this.bookingId,
    this.lastMessagePreview,
    required this.lastMessageAt,
    required this.otherParticipant,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['room_id'],
      bookingId: json['booking_id'],
      lastMessagePreview: json['last_message_preview'],
      lastMessageAt: DateTime.parse(json['last_message_at']),
      otherParticipant: ChatParticipant.fromJson(json['otherParticipant']),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
