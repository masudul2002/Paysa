import 'package:isar/isar.dart';

import '../models/person_record.dart';
import 'people_local_datasource.dart';

/// Isar-backed implementation of [PeopleLocalDataSource].
final class IsarPeopleLocalDataSource implements PeopleLocalDataSource {
  const IsarPeopleLocalDataSource(this._isar);

  final Isar _isar;

  IsarCollection<PersonRecord> get _collection =>
      _isar.collection<PersonRecord>();

  @override
  Future<PersonRecord> put(PersonRecord record) async {
    final id = await _isar.writeTxn(() => _collection.put(record));
    final saved = await _collection.get(id);
    if (saved == null) {
      throw Exception('Failed to save person record.');
    }
    return saved;
  }

  @override
  Future<PersonRecord?> getById(int id) {
    return _collection.get(id);
  }

  @override
  Future<PersonRecord?> getByPhone(String phone) async {
    final normalized = phone.trim().toLowerCase();
    final all = await _collection.where().findAll();
    for (final record in all) {
      if (record.phone?.trim().toLowerCase() == normalized) {
        return record;
      }
    }
    return null;
  }

  @override
  Future<List<PersonRecord>> getAll() async {
    return _collection.where().findAll();
  }

  @override
  Stream<List<PersonRecord>> watchAll() {
    return _collection.watchLazy(fireImmediately: true).asyncMap((_) => getAll());
  }

  @override
  Future<void> delete(int id) {
    return _isar.writeTxn(() => _collection.delete(id));
  }
}
