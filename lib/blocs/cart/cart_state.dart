import '../../models/cart_model.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartModel> items;
  final CartSummaryModel summary;
  CartLoaded({required this.items, required this.summary});
}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}

class CartAddedSuccess extends CartState {
  final String message;
  CartAddedSuccess(this.message);
}

class CartActionSuccess extends CartState {
  final String message;
  CartActionSuccess(this.message);
}

class CartBuyNowSuccess extends CartState {
  final int cartId;
  CartBuyNowSuccess(this.cartId);
}
