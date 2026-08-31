class ProductModel {
  final int id;
  final int? categoryId;
  final int? bagCategoryId;
  final String code;
  final String slug;
  final String name;
  final String? image;
  final List<String> variantImages;
  final String? variantVideo;
  final num price;
  final num? discountPrice;
  final DateTime? discountStartDate;
  final DateTime? discountEndDate;
  final int stock;
  final num? weight;
  final num? length;
  final num? width;
  final num? height;
  final String? material;
  final List<String> color;
  final List<String> strapLength;
  final String? description;
  final String? descriptionEn;
  final String? design;
  final String? designEn;
  final String status;
  final bool isFinalSale;
  final int totalSold;

  // Untuk menampung data relasi jika di-load via with()
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? bagCategory;
  final List<dynamic>? stocks;

  ProductModel({
    required this.id,
    this.categoryId,
    this.bagCategoryId,
    required this.code,
    required this.slug,
    required this.name,
    this.image,
    required this.variantImages,
    this.variantVideo,
    required this.price,
    this.discountPrice,
    this.discountStartDate,
    this.discountEndDate,
    required this.stock,
    this.weight,
    this.length,
    this.width,
    this.height,
    this.material,
    required this.color,
    required this.strapLength,
    this.description,
    this.descriptionEn,
    this.design,
    this.designEn,
    required this.status,
    required this.isFinalSale,
    required this.totalSold,
    this.category,
    this.bagCategory,
    this.stocks,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      categoryId: json['category_id'] != null
          ? int.tryParse(json['category_id'].toString())
          : null,
      bagCategoryId: json['bag_category_id'] != null
          ? int.tryParse(json['bag_category_id'].toString())
          : null,
      code: json['code']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      image: json['image']?.toString(),
      // Mencegah error jika array kosong
      variantImages: json['variant_images'] != null
          ? List<String>.from(json['variant_images'])
          : [],
      variantVideo: json['variant_video']?.toString(),
      price: num.tryParse(json['price']?.toString() ?? '0') ?? 0,
      discountPrice: json['discount_price'] != null
          ? num.tryParse(json['discount_price'].toString())
          : null,
      discountStartDate: json['discount_start_date'] != null
          ? DateTime.tryParse(json['discount_start_date'].toString())
          : null,
      discountEndDate: json['discount_end_date'] != null
          ? DateTime.tryParse(json['discount_end_date'].toString())
          : null,
      stock: json['stock'] != null
          ? int.tryParse(json['stock'].toString()) ?? 0
          : 0,
      weight: json['weight'] != null
          ? num.tryParse(json['weight'].toString())
          : null,
      length: json['length'] != null
          ? num.tryParse(json['length'].toString())
          : null,
      width:
          json['width'] != null ? num.tryParse(json['width'].toString()) : null,
      height: json['height'] != null
          ? num.tryParse(json['height'].toString())
          : null,
      material: json['material']?.toString(),
      // Array parser yang kebal error
      color: json['color'] != null ? List<String>.from(json['color']) : [],
      strapLength: json['strap_length'] != null
          ? List<String>.from(json['strap_length'])
          : [],
      description: json['description']?.toString(),
      descriptionEn: json['description_en']?.toString(),
      design: json['design']?.toString(),
      designEn: json['design_en']?.toString(),
      status: json['status']?.toString() ?? 'active',
      isFinalSale: json['is_final_sale'] == 1 || json['is_final_sale'] == true,
      totalSold: json['total_sold'] != null
          ? int.tryParse(json['total_sold'].toString()) ?? 0
          : 0,
      // Map Relasi
      category: json['category'] as Map<String, dynamic>?,
      bagCategory: json['bag_category'] as Map<String, dynamic>?,
      stocks: json['stocks'] as List<dynamic>?,
    );
  }

  // FUNGSI PINTAR (HELPER) UNTUK TAMPILAN UI
  // Otomatis menentukan apakah produk sedang diskon hari ini berdasarkan tanggal
  num get currentPrice {
    if (discountPrice != null &&
        discountStartDate != null &&
        discountEndDate != null) {
      final now = DateTime.now();
      if (now.isAfter(discountStartDate!) && now.isBefore(discountEndDate!)) {
        return discountPrice!;
      }
    }
    return price;
  }

  bool get hasActiveDiscount {
    if (discountPrice != null && 
        discountPrice! > 0 && 
        discountStartDate != null && 
        discountEndDate != null) {
      final now = DateTime.now();
      // Validasi ketat: Apakah waktu saat ini berada di dalam rentang diskon?
      return now.isAfter(discountStartDate!) && now.isBefore(discountEndDate!);
    }
    return false;
  }
}
