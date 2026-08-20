import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/product_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ProductRepository productRepository;

  // Injeksi Repository melalui Constructor (Standar Clean Architecture)
  HomeBloc({required this.productRepository}) : super(HomeInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
  }

  Future<void> _onFetchHomeData(FetchHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      // Tembak 2 fungsi di repository secara paralel
      final results = await Future.wait([
        productRepository.fetchBestSellers(),
        productRepository.fetchActiveProducts(),
      ]);

      emit(HomeLoaded(
        bestSellers: results[0],
        activeProducts: results[1],
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}