class ChatAdminModel {
  final int id;
  final String firstName;
  final String lastName;
  final String usertype;
  final int unreadCount;

  ChatAdminModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.usertype,
    this.unreadCount = 0,
  });

  factory ChatAdminModel.fromJson(Map<String, dynamic> json) {
    return ChatAdminModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? 'Admin',
      lastName: json['last_name'] ?? '',
      usertype: json['usertype'] ?? 'admin',
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class ChatMessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final String createdAt;
  final Map<String, dynamic>? sender;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
    this.sender,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      sender: json['sender'],
    );
  }
}
