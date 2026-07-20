import '../entities/category.dart';
import '../repositories/category_repository.dart';

final class WatchCategories {
  const WatchCategories(this._repository);

  final CategoryRepository _repository;

  Stream<List<Category>> call() => _repository.watchCategories();
}
