class SubscriberModel {
  final int id;
  final String email;
  final bool isRegistered;
  final bool isActive;

  SubscriberModel({
    required this.id,
    required this.email,
    required this.isRegistered,
    required this.isActive,
  });

  factory SubscriberModel.fromJson(Map<String, dynamic> json) {
    return SubscriberModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      email: json['email'] ?? '',
      isRegistered: json['is_registered'] == 1 || json['is_registered'] == true,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}
