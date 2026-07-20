import '../models/category_record.dart';

abstract interface class CategoriesLocalDataSource {
  Future<List<CategoryRecord>> getAll();

  Stream<List<CategoryRecord>> watchAll();

  Future<CategoryRecord?> getById(int id);

  Future<CategoryRecord?> getByName(String name);

  Future<int> put(CategoryRecord record);

  Future<void> delete(int id);
}
