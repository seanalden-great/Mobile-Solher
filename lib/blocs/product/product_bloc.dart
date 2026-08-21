import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_event.dart';
import 'product_state.dart';
import '../../repositories/product_repository.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    // 1. Ambil Semua Produk Aktif (Default)
    on<FetchActiveProductsEvent>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await productRepository.fetchActiveProducts();
        emit(ProductListLoaded(products));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    // 👇 [BARU] 2. Ambil Produk Berdasarkan Filter Kategori 👇
    on<FetchProductsByCategoryEvent>((event, emit) async {
      emit(ProductLoading()); // Memunculkan indikator loading
      try {
        final products =
            await productRepository.fetchProductsByCategory(event.categoryId);
        emit(ProductListLoaded(
            products)); // Menampilkan produk yang sudah difilter
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    // 3. Ambil Produk Best Seller
    on<FetchBestSellersEvent>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await productRepository.fetchBestSellers();
        emit(ProductListLoaded(products));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    // 4. Cari Produk berdasarkan Keyword
    on<SearchProductsEvent>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await productRepository.searchProducts(event.keyword);
        emit(ProductListLoaded(products));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    // 5. Ambil Detail Produk Lengkap
    on<FetchProductDetailEvent>((event, emit) async {
      emit(ProductLoading());
      try {
        final product =
            await productRepository.fetchProductDetail(event.identifier);
        emit(ProductDetailLoaded(product));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    // 6. Ambil Daftar Produk Inaktif
    on<FetchInactiveProductsEvent>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await productRepository.fetchInactiveProducts();
        emit(ProductListLoaded(products));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });
  }
}
