import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/wishlist_repository.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository wishlistRepository;

  WishlistBloc({required this.wishlistRepository}) : super(WishlistInitial()) {
    on<FetchWishlists>((event, emit) async {
      emit(WishlistLoading());
      try {
        final wishlists = await wishlistRepository.fetchWishlists();
        emit(WishlistLoaded(wishlists));
      } catch (e) {
        emit(WishlistError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<ToggleWishlistEvent>((event, emit) async {
      try {
        final result = await wishlistRepository.toggleWishlist(event.productId);
        emit(WishlistToggleSuccess(result['message'] ?? 'Berhasil'));
        // Otomatis mengambil ulang daftar terbaru agar UI ter-update
        add(FetchWishlists());
      } catch (e) {
        emit(WishlistError(e.toString().replaceAll('Exception: ', '')));
        add(FetchWishlists());
      }
    });
  }
}
