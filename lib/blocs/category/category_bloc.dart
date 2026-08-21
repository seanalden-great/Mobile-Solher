import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';
import '../../repositories/category_repository.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryBloc({required this.categoryRepository}) : super(CategoryInitial()) {
    on<FetchCategories>((event, emit) async {
      emit(CategoryLoading());
      try {
        final categories = await categoryRepository.getCategories();
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<FetchCategoryDetail>((event, emit) async {
      emit(CategoryLoading());
      try {
        final category = await categoryRepository.getCategoryById(event.id);
        emit(CategoryDetailLoaded(category));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<CreateCategoryEvent>((event, emit) async {
      emit(CategoryLoading());
      try {
        await categoryRepository.createCategory(event.category);
        emit(const CategoryActionSuccess('Kategori berhasil ditambahkan.'));
        add(FetchCategories()); // Refresh data
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<UpdateCategoryEvent>((event, emit) async {
      emit(CategoryLoading());
      try {
        await categoryRepository.updateCategory(event.id, event.category);
        emit(const CategoryActionSuccess('Kategori berhasil diperbarui.'));
        add(FetchCategories()); // Refresh data
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<DeleteCategoryEvent>((event, emit) async {
      emit(CategoryLoading());
      try {
        await categoryRepository.deleteCategory(event.id);
        emit(const CategoryActionSuccess('Kategori berhasil dihapus.'));
        add(FetchCategories()); // Refresh data
      } catch (e) {
        // Akan menangkap error 409 yang dilempar dari repository
        emit(CategoryError(e.toString()));
      }
    });
  }
}
