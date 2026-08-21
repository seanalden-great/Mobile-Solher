import 'package:equatable/equatable.dart';
import 'package:solher_mobile/models/category_model.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchCategories extends CategoryEvent {}

class FetchCategoryDetail extends CategoryEvent {
  final int id;
  const FetchCategoryDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateCategoryEvent extends CategoryEvent {
  final Category category;
  const CreateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategoryEvent extends CategoryEvent {
  final int id;
  final Category category;
  const UpdateCategoryEvent(this.id, this.category);

  @override
  List<Object?> get props => [id, category];
}

class DeleteCategoryEvent extends CategoryEvent {
  final int id;
  const DeleteCategoryEvent(this.id);

  @override
  List<Object?> get props => [id];
}
