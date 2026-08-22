class ProductStockModel {
  final String batchCode;
  final int quantity;
  final int initialQuantity;

  ProductStockModel(
      {required this.batchCode,
      required this.quantity,
      required this.initialQuantity});

  factory ProductStockModel.fromJson(Map<String, dynamic> json) {
    return ProductStockModel(
      batchCode: json['batch_code'] ?? '',
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      initialQuantity: int.tryParse(json['initial_quantity'].toString()) ?? 0,
    );
  }
}
