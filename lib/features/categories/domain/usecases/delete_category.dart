import 'package:paysa/core/app_exception.dart';
import '../repositories/category_repository.dart';

final class DeleteCategory {
  const DeleteCategory(this._repository);

  final CategoryRepository _repository;

  Future<void> call(int id) async {
    if (id <= 0) {
      throw AppException('Invalid category.');
    }

    return _repository.deleteCategory(id);
  }
}
