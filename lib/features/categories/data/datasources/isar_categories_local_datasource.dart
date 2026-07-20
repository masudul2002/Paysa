import 'package:isar/isar.dart';

import '../models/category_record.dart';
import 'categories_local_datasource.dart';

final class IsarCategoriesLocalDataSource implements CategoriesLocalDataSource {
  const IsarCategoriesLocalDataSource(this._isar);

  final Isar _isar;

  IsarCollection<CategoryRecord> get _collection =>
      _isar.collection<CategoryRecord>();

  @override
  Future<List<CategoryRecord>> getAll() async {
    return _collection.where().findAll();
  }

  @override
  Stream<List<CategoryRecord>> watchAll() {
    return _collection.watchLazy(fireImmediately: true).asyncMap((_) => getAll());
  }

  @override
  Future<CategoryRecord?> getById(int id) {
    return _collection.get(id);
  }

  @override
  Future<CategoryRecord?> getByName(String name) async {
    final normalized = name.trim().toLowerCase();
    final records = await getAll();
    for (final record in records) {
      if (record.name.trim().toLowerCase() == normalized) {
        return record;
      }
    }
    return null;
  }

  @override
  Future<int> put(CategoryRecord record) {
    return _isar.writeTxn(() => _collection.put(record));
  }

  @override
  Future<void> delete(int id) {
    return _isar.writeTxn(() => _collection.delete(id));
  }
}
