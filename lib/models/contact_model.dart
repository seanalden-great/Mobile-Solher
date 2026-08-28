class ContactModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String description;
  final bool isRead;
  final String? response;
  final String createdAt;

  ContactModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.description,
    required this.isRead,
    this.response,
    required this.createdAt,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      description: json['description'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      response: json['response'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
