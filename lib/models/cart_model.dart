import 'product_model.dart';

class CartSummaryModel {
  final String currency;
  final num subtotal;
  final num bundleDiscount;
  final num grandTotal;

  CartSummaryModel({
    required this.currency,
    required this.subtotal,
    required this.bundleDiscount,
    required this.grandTotal,
  });

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    return CartSummaryModel(
      currency: json['currency'] ?? 'IDR',
      subtotal: num.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      bundleDiscount:
          num.tryParse(json['bundle_discount']?.toString() ?? '0') ?? 0,
      grandTotal: num.tryParse(json['grand_total']?.toString() ?? '0') ?? 0,
    );
  }
}

class CartModel {
  final int id;
  final int productId;
  final int quantity;
  final String? color;
  final num grossAmount;
  final ProductModel? product;

  CartModel({
    required this.id,
    required this.productId,
    required this.quantity,
    this.color,
    required this.grossAmount,
    this.product,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      color: json['color'],
      grossAmount: num.tryParse(json['gross_amount']?.toString() ?? '0') ?? 0,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
    );
  }
}
