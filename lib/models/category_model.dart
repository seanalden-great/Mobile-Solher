class Category {
  final int? id;
  final String code;
  final String name;
  final String? description;
  final int? bundleQty;
  final dynamic bundlePrice; // Di PHP di-cast sebagai array
  final DateTime? bundleStartDate;
  final DateTime? bundleEndDate;
  // Jika relasi products di-load
  final List<dynamic>? products;

  Category({
    this.id,
    required this.code,
    required this.name,
    this.description,
    this.bundleQty,
    this.bundlePrice,
    this.bundleStartDate,
    this.bundleEndDate,
    this.products,
  });

  // factory Category.fromJson(Map<String, dynamic> json) {
  //   // Menyesuaikan dengan struktur CategoryResource yang umumnya me-wrap data
  //   final data = json.containsKey('data') ? json['data'] : json;

  //   return Category(
  //     id: data['id'],
  //     code: data['code'],
  //     name: data['name'],
  //     description: data['description'],
  //     bundleQty: data['bundle_qty'],
  //     bundlePrice: data['bundle_price'],
  //     bundleStartDate: data['bundle_start_date'] != null
  //         ? DateTime.parse(data['bundle_start_date'])
  //         : null,
  //     bundleEndDate: data['bundle_end_date'] != null
  //         ? DateTime.parse(data['bundle_end_date'])
  //         : null,
  //     products: data['products'], // Bisa dibuatkan ProductModel terpisah nanti
  //   );
  // }

factory Category.fromJson(Map<String, dynamic> json) {
    // Menyesuaikan dengan struktur CategoryResource
    final data = json.containsKey('data') ? json['data'] : json;

    return Category(
      id: data['id'] is int
          ? data['id']
          : int.tryParse(data['id']?.toString() ?? '0'),

      // 👇 Disesuaikan dengan key JSON dari Laravel 👇
      code: data['category_code']?.toString() ?? '',
      name: data['category_name']?.toString() ?? 'Unknown Category',

      // 👇 Description sekarang ada di dalam object 'meta' 👇
      description:
          data['meta'] != null ? data['meta']['description']?.toString() : null,

      // 👇 Data bundle sekarang berada di dalam object 'bundle_promo' 👇
      bundleQty:
          data['bundle_promo'] != null && data['bundle_promo']['qty'] != null
              ? (data['bundle_promo']['qty'] is int
                  ? data['bundle_promo']['qty']
                  : int.tryParse(data['bundle_promo']['qty'].toString()))
              : null,
      bundlePrice:
          data['bundle_promo'] != null ? data['bundle_promo']['price'] : null,
      bundleStartDate: data['bundle_promo'] != null &&
              data['bundle_promo']['start_date'] != null
          ? DateTime.tryParse(data['bundle_promo']['start_date'].toString())
          : null,
      bundleEndDate: data['bundle_promo'] != null &&
              data['bundle_promo']['end_date'] != null
          ? DateTime.tryParse(data['bundle_promo']['end_date'].toString())
          : null,

      products: data['products'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'bundle_qty': bundleQty,
      'bundle_price': bundlePrice,
      'bundle_start_date': bundleStartDate?.toIso8601String(),
      'bundle_end_date': bundleEndDate?.toIso8601String(),
    };
  }
}
