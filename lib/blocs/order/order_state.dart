import '../../models/transaction_models.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<TransactionModel> orders;
  OrderLoaded(this.orders);
}

class OrderDetailLoaded extends OrderState {
  final TransactionModel order;
  OrderDetailLoaded(this.order);
}

class OrderCheckoutSuccess extends OrderState {
  final Map<String, dynamic> checkoutResponse;
  OrderCheckoutSuccess(this.checkoutResponse);
}

class OrderTrackingLoaded extends OrderState {
  final Map<String, dynamic> trackingData;
  OrderTrackingLoaded(this.trackingData);
}

class BulkOrderTrackingLoaded extends OrderState {
  final Map<String, dynamic> bulkTrackingData;
  BulkOrderTrackingLoaded(this.bulkTrackingData);
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}

// State untuk memicu SnackBar/Notifikasi Sukses
class OrderActionSuccess extends OrderState {
  final String message;
  OrderActionSuccess(this.message);
}
