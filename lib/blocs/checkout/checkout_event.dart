abstract class CheckoutEvent {}

class SubmitCheckoutEvent extends CheckoutEvent {
  final Map<String, dynamic> payload;
  SubmitCheckoutEvent(this.payload);
}
