import '../../models/wishlist_model.dart';

abstract class WishlistState {}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final List<WishlistModel> wishlists;
  WishlistLoaded(this.wishlists);
}

class WishlistError extends WishlistState {
  final String message;
  WishlistError(this.message);
}

class WishlistToggleSuccess extends WishlistState {
  final String message;
  WishlistToggleSuccess(this.message);
}
