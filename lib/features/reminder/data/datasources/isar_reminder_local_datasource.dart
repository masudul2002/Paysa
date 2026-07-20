import 'package:isar/isar.dart';

import '../models/reminder_record.dart';
import 'reminder_local_datasource.dart';

final class IsarReminderLocalDataSource implements ReminderLocalDataSource {
  const IsarReminderLocalDataSource(this._isar);

  final Isar _isar;

  IsarCollection<ReminderRecord> get _collection =>
      _isar.collection<ReminderRecord>();

  @override
  Future<ReminderRecord> put(ReminderRecord record) async {
    final id = await _isar.writeTxn(() => _collection.put(record));
    final saved = await _collection.get(id);
    if (saved == null) throw Exception('Failed to save reminder.');
    return saved;
  }

  @override
  Future<ReminderRecord?> getById(int id) => _collection.get(id);

  @override
  Future<ReminderRecord?> getByLedgerEntryId(int ledgerEntryId) async {
    final all = await _collection.where().findAll();
    for (final r in all) {
      if (r.ledgerEntryId == ledgerEntryId && r.deletedAt == null) return r;
    }
    return null;
  }

  @override
  Future<List<ReminderRecord>> getAll() async {
    return _collection.where().findAll();
  }

  @override
  Future<List<ReminderRecord>> getOverdue() async {
    final all = await _collection.where().findAll();
    final now = DateTime.now();
    return all.where((r) =>
        r.deletedAt == null && r.isActive && r.dueDate.isBefore(now)).toList();
  }

  @override
  Future<List<ReminderRecord>> getUpcoming() async {
    final all = await _collection.where().findAll();
    final now = DateTime.now();
    return all.where((r) =>
        r.deletedAt == null && r.isActive && r.dueDate.isAfter(now)).toList();
  }

  @override
  Future<List<ReminderRecord>> getByPersonId(int personId) async {
    final all = await _collection.where().findAll();
    return all.where((r) =>
        r.personId == personId && r.deletedAt == null).toList();
  }

  @override
  Future<void> delete(int id) {
    return _isar.writeTxn(() => _collection.delete(id));
  }
}
