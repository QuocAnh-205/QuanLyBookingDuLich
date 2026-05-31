class NotificationModel {
  final int notifId;
  final int userId;
  final String category;
  final String title;
  final String message;
  final String? relatedEntityType;
  final int? relatedEntityId;
  final bool isRead;
  final DateTime? readAt;
  final Map<String, dynamic>? extraData;
  final DateTime createdAt;

  NotificationModel({
    required this.notifId,
    required this.userId,
    required this.category,
    required this.title,
    required this.message,
    this.relatedEntityType,
    this.relatedEntityId,
    required this.isRead,
    this.readAt,
    this.extraData,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notifId: json['notif_id'],
      userId: json['user_id'],
      category: json['category'],
      title: json['title'],
      message: json['message'],
      relatedEntityType: json['related_entity_type'],
      relatedEntityId: json['related_entity_id'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      extraData: json['extra_data'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notif_id': notifId,
      'user_id': userId,
      'category': category,
      'title': title,
      'message': message,
      'related_entity_type': relatedEntityType,
      'related_entity_id': relatedEntityId,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'extra_data': extraData,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
