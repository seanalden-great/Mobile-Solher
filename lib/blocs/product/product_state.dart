import 'package:equatable/equatable.dart';
import 'package:solher_mobile/models/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

// Digunakan untuk menampung hasil dari list biasa, best seller, pencarian, maupun inaktif
class ProductListLoaded extends ProductState {
  final List<ProductModel> products;

  const ProductListLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

// Digunakan khusus untuk halaman detail produk
class ProductDetailLoaded extends ProductState {
  final ProductModel product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
