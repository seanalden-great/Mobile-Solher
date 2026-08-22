abstract class WishlistEvent {}

class FetchWishlists extends WishlistEvent {}

class ToggleWishlistEvent extends WishlistEvent {
  final int productId;
  ToggleWishlistEvent(this.productId);
}
