class ShippingRateModel {
  final String company;
  final String type;
  final String courierName;
  final String duration;
  final num price;
  final bool isDisabled;

  ShippingRateModel({
    required this.company,
    required this.type,
    required this.courierName,
    required this.duration,
    required this.price,
    this.isDisabled = false,
  });

  factory ShippingRateModel.fromJson(Map<String, dynamic> json) {
    // Penyesuaian membaca format Biteship / Shippo
    bool isShippo = json['provider'] != null;
    return ShippingRateModel(
      company: isShippo ? json['provider'] : json['company'],
      type: isShippo ? json['service_name'] : json['type'],
      courierName: isShippo
          ? 'Global Express'
          : (json['courier_name'] ?? json['company']),
      duration: isShippo ? json['etd'] : (json['duration'] ?? '1-3 days'),
      price: num.tryParse(json['price']?.toString() ?? '0') ?? 0,
      isDisabled: false,
    );
  }
}
