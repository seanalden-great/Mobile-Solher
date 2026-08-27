abstract class CheckoutState {}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final String checkoutUrl;
  CheckoutSuccess(this.checkoutUrl);
}

class CheckoutError extends CheckoutState {
  final String message;
  CheckoutError(this.message);
}
