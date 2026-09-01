// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'product_event.dart';
// import 'product_state.dart';
// import '../../repositories/product_repository.dart';

// class ProductBloc extends Bloc<ProductEvent, ProductState> {
//   final ProductRepository productRepository;

//   ProductBloc({required this.productRepository}) : super(ProductInitial()) {
//     // 1. Ambil Semua Produk Aktif (Default)
//     on<FetchActiveProductsEvent>((event, emit) async {
//       emit(ProductLoading());
//       try {
//         final products = await productRepository.fetchActiveProducts();
//         emit(ProductListLoaded(products));
//       } catch (e) {
//         emit(ProductError(e.toString()));
//       }
//     });

//     // 👇 [BARU] 2. Ambil Produk Berdasarkan Filter Kategori 👇
//     on<FetchProductsByCategoryEvent>((event, emit) async {
//       emit(ProductLoading()); // Memunculkan indikator loading
//       try {
//         final products =
//             await productRepository.fetchProductsByCategory(event.categoryId);
//         emit(ProductListLoaded(
//             products)); // Menampilkan produk yang sudah difilter
//       } catch (e) {
//         emit(ProductError(e.toString()));
//       }
//     });

//     // 3. Ambil Produk Best Seller
//     on<FetchBestSellersEvent>((event, emit) async {
//       emit(ProductLoading());
//       try {
//         final products = await productRepository.fetchBestSellers();
//         emit(ProductListLoaded(products));
//       } catch (e) {
//         emit(ProductError(e.toString()));
//       }
//     });

//     // 4. Cari Produk berdasarkan Keyword
//     on<SearchProductsEvent>((event, emit) async {
//       emit(ProductLoading());
//       try {
//         final products = await productRepository.searchProducts(event.keyword);
//         emit(ProductListLoaded(products));
//       } catch (e) {
//         emit(ProductError(e.toString()));
//       }
//     });

//     // 5. Ambil Detail Produk Lengkap
//     on<FetchProductDetailEvent>((event, emit) async {
//       emit(ProductLoading());
//       try {
//         final product =
//             await productRepository.fetchProductDetail(event.identifier);
//         emit(ProductDetailLoaded(product));
//       } catch (e) {
//         emit(ProductError(e.toString()));
//       }
//     });

//     // 6. Ambil Daftar Produk Inaktif
//     on<FetchInactiveProductsEvent>((event, emit) async {
//       emit(ProductLoading());
//       try {
//         final products = await productRepository.fetchInactiveProducts();
//         emit(ProductListLoaded(products));
//       } catch (e) {
//         emit(ProductError(e.toString()));
//       }
//     });
//   }
// }

import 'package:hydrated_bloc/hydrated_bloc.dart'; // 👇 IMPORT HYDRATED BLOC
import 'product_event.dart';
import 'product_state.dart';
import '../../models/product_model.dart';
import '../../repositories/product_repository.dart';

// 👇 UBAH EXTENDS MENJADI HydratedBloc 👇
class ProductBloc extends HydratedBloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    // 1. Ambil Semua Produk Aktif
    on<FetchActiveProductsEvent>((event, emit) async {
      // 🚀 OPTIMISASI UX: Hanya tampilkan loading jika CACHE KOSONG
      if (state is! ProductListLoaded) {
        emit(ProductLoading());
      }
      try {
        final products = await productRepository.fetchActiveProducts();
        emit(ProductListLoaded(products)); // Akan menimpa cache lama
      } catch (e) {
        // Jika tidak ada koneksi DAN tidak ada cache, baru tampilkan error
        if (state is! ProductListLoaded) {
          emit(ProductError(e.toString()));
        }
      }
    });

    // 2. Ambil Produk Berdasarkan Filter Kategori
    on<FetchProductsByCategoryEvent>((event, emit) async {
      emit(ProductLoading()); // Sengaja diberi loading karena ganti kategori
      try {
        final products =
            await productRepository.fetchProductsByCategory(event.categoryId);
        emit(ProductListLoaded(products));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    // 3. Ambil Produk Best Seller
    on<FetchBestSellersEvent>((event, emit) async {
      if (state is! ProductListLoaded) emit(ProductLoading());
      try {
        final products = await productRepository.fetchBestSellers();
        emit(ProductListLoaded(products));
      } catch (e) {
        if (state is! ProductListLoaded) emit(ProductError(e.toString()));
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

  // =========================================================================
  // 👇 SISTEM SINKRONISASI LOKAL HYDRATED BLOC (PENYIMPANAN OFFLINE) 👇
  // =========================================================================

  @override
  ProductState? fromJson(Map<String, dynamic> json) {
    try {
      // Menarik data JSON dari penyimpanan memori HP ke layar
      if (json['products'] != null) {
        final products = (json['products'] as List)
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return ProductListLoaded(products);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ProductState state) {
    // Menyimpan data produk ke memori HP saat berhasil di-fetch
    if (state is ProductListLoaded) {
      return {
        'products': state.products.map((p) => p.toJson()).toList(),
      };
    }
    return null;
  }
}
