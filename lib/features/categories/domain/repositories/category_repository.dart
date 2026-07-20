import '../entities/category.dart';

abstract interface class CategoryRepository {
  Future<Category> createCategory(Category category);

  Future<Category> updateCategory(Category category);

  Future<void> deleteCategory(int id);

  Future<List<Category>> getCategories();

  Future<List<Category>> getCategoriesByType(CategoryType type);

  Stream<List<Category>> watchCategories();
}
