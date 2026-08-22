import 'product_model.dart'; // Pastikan path ini sesuai

class TransactionModel {
  final int id;
  final String orderId;
  final num totalAmount;
  final String status;
  final String shippingMethod;
  final num shippingCost;
  final String? paymentMethod;
  final String? courierCompany;
  final String? courierType;
  final String? trackingNumber;
  final String? shippingStatus;
  final int point;
  final int pointsUsed;
  final String? promoCode;
  final num promoDiscount;
  final String currencyCode;
  final String createdAt;
  final PaymentModel? payment;
  final List<TransactionDetailModel> details;

  TransactionModel({
    required this.id,
    required this.orderId,
    required this.totalAmount,
    required this.status,
    required this.shippingMethod,
    required this.shippingCost,
    this.paymentMethod,
    this.courierCompany,
    this.courierType,
    this.trackingNumber,
    this.shippingStatus,
    required this.point,
    required this.pointsUsed,
    this.promoCode,
    required this.promoDiscount,
    required this.currencyCode,
    required this.createdAt,
    this.payment,
    required this.details,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? '',
      totalAmount: num.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'pending',
      shippingMethod: json['shipping_method'] ?? '',
      shippingCost: num.tryParse(json['shipping_cost']?.toString() ?? '0') ?? 0,
      paymentMethod: json['payment_method'],
      courierCompany: json['courier_company'],
      courierType: json['courier_type'],
      trackingNumber: json['tracking_number'],
      shippingStatus: json['shipping_status'],
      point: json['point'] != null
          ? int.tryParse(json['point'].toString()) ?? 0
          : 0,
      pointsUsed: json['points_used'] != null
          ? int.tryParse(json['points_used'].toString()) ?? 0
          : 0,
      promoCode: json['promo_code'],
      promoDiscount:
          num.tryParse(json['promo_discount']?.toString() ?? '0') ?? 0,
      currencyCode: json['currency_code'] ?? 'IDR',
      createdAt: json['created_at'] ?? '',
      payment: json['payment'] != null
          ? PaymentModel.fromJson(json['payment'])
          : null,
      details: json['details'] != null
          ? (json['details'] as List)
              .map((i) => TransactionDetailModel.fromJson(i))
              .toList()
          : [],
    );
  }

  // Helper Grand Total (Harga Barang + Ongkir - Diskon)
  num get grandTotal =>
      totalAmount + shippingCost - promoDiscount - (pointsUsed * 1000);
}

class TransactionDetailModel {
  final int id;
  final int productId;
  final int quantity;
  final num price;
  final String? color;
  final ProductModel? product;

  TransactionDetailModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    this.color,
    this.product,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] != null
          ? int.tryParse(json['quantity'].toString()) ?? 0
          : 0,
      price: num.tryParse(json['price']?.toString() ?? '0') ?? 0,
      color: json['color'],
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
    );
  }
}

class PaymentModel {
  final int id;
  final String externalId;
  final String? checkoutUrl;
  final num amount;
  final String status;

  PaymentModel(
      {required this.id,
      required this.externalId,
      this.checkoutUrl,
      required this.amount,
      required this.status});

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      externalId: json['external_id'] ?? '',
      checkoutUrl: json['checkout_url'],
      amount: num.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? '',
    );
  }
}
