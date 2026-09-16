import '../../models/transaction_models.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

// class OrderLoaded extends OrderState {
//   final List<TransactionModel> orders;
//   OrderLoaded(this.orders);
// }

class OrderLoaded extends OrderState {
  final List<TransactionModel> orders;
  final bool hasReachedMax;
  final int currentPage;

  OrderLoaded({
    required this.orders,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  OrderLoaded copyWith({
    List<TransactionModel>? orders,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return OrderLoaded(
      orders: orders ?? this.orders,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [orders, hasReachedMax, currentPage];
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
