import '../entities/category.dart';
import '../repositories/category_repository.dart';

final class GetCategories {
  const GetCategories(this._repository);

  final CategoryRepository _repository;

  Future<List<Category>> call() => _repository.getCategories();
}
