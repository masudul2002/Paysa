import 'package:paysa/core/app_exception.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

final class CreateCategory {
  const CreateCategory(this._repository);

  final CategoryRepository _repository;

  Future<Category> call(Category category) async {
    if (category.name.trim().isEmpty) {
      throw AppException('Category name cannot be empty.');
    }

    return _repository.createCategory(category);
  }
}
