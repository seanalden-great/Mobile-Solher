import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class FetchActiveProductsEvent extends ProductEvent {}

class FetchBestSellersEvent extends ProductEvent {}

class FetchInactiveProductsEvent extends ProductEvent {}

class SearchProductsEvent extends ProductEvent {
  final String keyword;

  const SearchProductsEvent(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class FetchProductDetailEvent extends ProductEvent {
  final String identifier; // Bisa berupa ID atau Slug

  const FetchProductDetailEvent(this.identifier);

  @override
  List<Object?> get props => [identifier];
}

class FetchProductsByCategoryEvent extends ProductEvent {
  final int categoryId;

  const FetchProductsByCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
