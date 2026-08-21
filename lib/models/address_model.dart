class AddressModel {
  final int? id;
  // Receiver
  final String firstName;
  final String lastName;
  final String? fullName; // Read-only dari backend
  // Details
  final String region;
  final String location; // address_location
  final String? type; // location_type
  final String city;
  final String province;
  final String postalCode;
  final String? latitude;
  final String? longitude;
  // Root
  final bool isDefault;
  final String? createdAt;

  AddressModel({
    this.id,
    required this.firstName,
    required this.lastName,
    this.fullName,
    required this.region,
    required this.location,
    this.type,
    required this.city,
    required this.province,
    required this.postalCode,
    this.latitude,
    this.longitude,
    required this.isDefault,
    this.createdAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    // Karena Laravel menggunakan JsonResource::collection, biasanya data dibungkus
    final data = json.containsKey('data') ? json['data'] : json;

    // Mengekstrak dari struktur AddressResource.php
    final receiver = data['receiver'] ?? {};
    final details = data['details'] ?? {};

    return AddressModel(
      id: data['id'],
      firstName: receiver['first_name']?.toString() ?? '',
      lastName: receiver['last_name']?.toString() ?? '',
      fullName: receiver['full_name']?.toString(),
      region: details['region']?.toString() ?? '',
      location: details['location']?.toString() ?? '',
      type: details['type']?.toString(),
      city: details['city']?.toString() ?? '',
      province: details['province']?.toString() ?? '',
      postalCode: details['postal_code']?.toString() ?? '',
      latitude: details['latitude']?.toString(),
      longitude: details['longitude']?.toString(),
      isDefault: data['is_default'] ?? false,
      createdAt: data['created_at']?.toString(),
    );
  }

  // Format ini wajib sesuai dengan AddressRequest.php di Laravel
  Map<String, dynamic> toJson() {
    return {
      'first_name_address': firstName,
      'last_name_address': lastName,
      'region': region,
      'address_location': location,
      'location_type': type ?? 'other',
      'city': city,
      'province': province,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault, // Laravel bisa menerima boolean atau 1/0
    };
  }
}
