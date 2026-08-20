class ProductModel {
  final int id;
  final String name;
  final String? image;
  final num price;

  ProductModel({
    required this.id,
    required this.name,
    this.image,
    required this.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'Unknown',
      image: json['image'],
      // 👇 PERBAIKAN ERROR: Memaksa konversi String dari Laravel menjadi Angka
      price: num.tryParse(json['price'].toString()) ?? 0,
    );
  }
}