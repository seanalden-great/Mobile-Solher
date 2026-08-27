import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc({required this.cartRepository}) : super(CartInitial()) {
    on<FetchCartEvent>((event, emit) async {
      emit(CartLoading());
      try {
        final result = await cartRepository.fetchCarts();
        emit(CartLoaded(items: result['items'], summary: result['summary']));
      } catch (e) {
        emit(CartError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<AddToCartEvent>((event, emit) async {
      emit(CartLoading());
      try {
        await cartRepository.addToCart(
            event.productId, event.quantity, event.color);
        emit(CartAddedSuccess('Berhasil ditambahkan ke Tas!'));
        add(FetchCartEvent()); // Muat ulang isi keranjang
      } catch (e) {
        emit(CartError(e.toString().replaceAll('Exception: ', '')));
        add(FetchCartEvent());
      }
    });

    on<UpdateCartQtyEvent>((event, emit) async {
      try {
        await cartRepository.updateCartQty(event.cartId, event.quantity);
        add(FetchCartEvent());
      } catch (e) {
        emit(CartError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<DeleteCartItemEvent>((event, emit) async {
      try {
        await cartRepository.deleteCartItem(event.cartId);
        emit(CartActionSuccess('Barang dihapus dari keranjang.'));
        add(FetchCartEvent());
      } catch (e) {
        emit(CartError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // Tambahkan blok ini di dalam CartBloc
    on<BuyNowEvent>((event, emit) async {
      emit(CartLoading());
      try {
        // Panggil API dan dapatkan ID nya
        final cartId = await cartRepository.buyNowReturnId(
            event.productId, event.quantity, event.color);
        emit(CartBuyNowSuccess(cartId));

        // Tetap refresh list keranjang di background
        add(FetchCartEvent());
      } catch (e) {
        emit(CartError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
