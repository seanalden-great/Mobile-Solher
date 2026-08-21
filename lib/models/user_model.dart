class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? profileImage;
  final String userType;
  final bool isMembership;
  final int point;
  final bool isSubscribed;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.profileImage,
    required this.userType,
    required this.isMembership,
    required this.point,
    required this.isSubscribed,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImage: json['profile_image'],
      userType: json['usertype'] ?? 'user',
      // Mengubah 1/0 dari MySQL atau true/false JSON menjadi bool murni
      isMembership: json['is_membership'] == 1 || json['is_membership'] == true,
      point: json['point'] is int
          ? json['point']
          : int.tryParse(json['point'].toString()) ?? 0,
      isSubscribed: json['is_subscribed'] == 1 || json['is_subscribed'] == true,
    );
  }

  // Helper untuk mendapatkan nama lengkap
  String get fullName => '$firstName $lastName';
}
