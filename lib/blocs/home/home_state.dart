import '../../models/product_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ProductModel> bestSellers;
  final List<ProductModel> activeProducts;

  HomeLoaded({required this.bestSellers, required this.activeProducts});
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}