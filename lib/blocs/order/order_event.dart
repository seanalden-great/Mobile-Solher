abstract class OrderEvent {}

class FetchOrders extends OrderEvent {}

class FetchOrderDetailRequested extends OrderEvent {
  final int transactionId;
  FetchOrderDetailRequested(this.transactionId);
}

class CheckoutRequested extends OrderEvent {
  final Map<String, dynamic> checkoutData;
  CheckoutRequested(this.checkoutData);
}

class CancelOrderRequested extends OrderEvent {
  final int transactionId;
  CancelOrderRequested(this.transactionId);
}

class ConfirmCompleteRequested extends OrderEvent {
  final int transactionId;
  ConfirmCompleteRequested(this.transactionId);
}

class RequestRefundRequested extends OrderEvent {
  final int transactionId;
  final String reason;
  final String filePath; // Path file gambar/video dari HP
  RequestRefundRequested(
      {required this.transactionId,
      required this.reason,
      required this.filePath});
}

class ProcessRefundRequested extends OrderEvent {
  final int transactionId;
  ProcessRefundRequested(this.transactionId);
}

class TrackOrderRequested extends OrderEvent {
  final int transactionId;
  TrackOrderRequested(this.transactionId);
}

class BulkTrackOrdersRequested extends OrderEvent {
  final List<int> transactionIds;
  BulkTrackOrdersRequested(this.transactionIds);
}
