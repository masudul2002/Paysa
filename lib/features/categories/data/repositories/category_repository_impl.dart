import '../../../../core/app_exception.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/categories_local_datasource.dart';
import '../models/category_record.dart';

final class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._localDataSource);

  final CategoriesLocalDataSource _localDataSource;

  @override
  Future<Category> createCategory(Category category) async {
    await _ensureUniqueName(category.name);

    final record = category.toRecord();
    final id = await _localDataSource.put(record);
    final saved = await _localDataSource.getById(id);
    if (saved == null) {
      throw AppException('Failed to create category.');
    }
    return saved.toEntity();
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final existing = await _localDataSource.getById(category.id);
    if (existing == null) {
      throw AppException('Category not found.');
    }
    await _ensureUniqueName(category.name, excludeId: category.id);

    final record = category.toRecord();
    await _localDataSource.put(record);
    final saved = await _localDataSource.getById(category.id);
    if (saved == null) {
      throw AppException('Failed to update category.');
    }
    return saved.toEntity();
  }

  @override
  Future<void> deleteCategory(int id) async {
    final existing = await _localDataSource.getById(id);
    if (existing == null) {
      throw AppException('Category not found.');
    }
    await _localDataSource.delete(id);
  }

  @override
  Future<List<Category>> getCategories() async {
    final records = await _localDataSource.getAll();
    return records.map((r) => r.toEntity()).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    final all = await getCategories();
    return all.where((c) => c.type == type).toList(growable: false);
  }

  @override
  Stream<List<Category>> watchCategories() {
    return _localDataSource.watchAll().map((records) {
      return records.map((r) => r.toEntity()).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> _ensureUniqueName(String name, {int? excludeId}) async {
    final categories = await _localDataSource.getAll();
    final normalized = name.trim().toLowerCase();
    final existing = categories.where((c) {
      return c.name.trim().toLowerCase() == normalized &&
          c.id != excludeId;
    }).toList(growable: false);
    if (existing.isNotEmpty) {
      throw AppException('A category with this name already exists.');
    }
  }
}
