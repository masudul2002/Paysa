import 'package:paysa/core/app_exception.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

final class UpdateCategory {
  const UpdateCategory(this._repository);

  final CategoryRepository _repository;

  Future<Category> call(Category category) async {
    if (category.id <= 0) {
      throw AppException('Invalid category.');
    }
    if (category.name.trim().isEmpty) {
      throw AppException('Category name cannot be empty.');
    }

    return _repository.updateCategory(category);
  }
}
