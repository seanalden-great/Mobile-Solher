class PromoClaimModel {
  final String promoCode;
  final num discountValue;
  final bool isUsed;

  PromoClaimModel(
      {required this.promoCode,
      required this.discountValue,
      required this.isUsed});

  factory PromoClaimModel.fromJson(Map<String, dynamic> json) {
    return PromoClaimModel(
      promoCode: json['promo_code'] ?? '',
      discountValue: num.tryParse(json['discount_value'].toString()) ?? 0,
      isUsed: json['is_used'] == 1 || json['is_used'] == true,
    );
  }
}
