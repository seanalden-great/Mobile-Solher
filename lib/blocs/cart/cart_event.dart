abstract class CartEvent {}

class FetchCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final int productId;
  final int quantity;
  final String color;
  AddToCartEvent(
      {required this.productId, required this.quantity, required this.color});
}

class UpdateCartQtyEvent extends CartEvent {
  final int cartId;
  final int quantity;
  UpdateCartQtyEvent(this.cartId, this.quantity);
}

class DeleteCartItemEvent extends CartEvent {
  final int cartId;
  DeleteCartItemEvent(this.cartId);
}

class BuyNowEvent extends CartEvent {
  final int productId;
  final int quantity;
  final String color;
  BuyNowEvent(
      {required this.productId, required this.quantity, required this.color});
}
