import 'product_model.dart'; // Sesuaikan path

class WishlistModel {
  final int id;
  final int productId;
  final ProductModel? product;

  WishlistModel({
    required this.id,
    required this.productId,
    this.product,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
    );
  }
}
