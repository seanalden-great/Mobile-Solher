import 'product_model.dart';

class CartModel {
  final int id;
  final int quantity;
  final String? color;
  final num grossAmount;
  final ProductModel? product;

  CartModel(
      {required this.id,
      required this.quantity,
      this.color,
      required this.grossAmount,
      this.product});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] ?? 0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      color: json['color'],
      grossAmount: num.tryParse(json['gross_amount'].toString()) ?? 0,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
    );
  }
}
