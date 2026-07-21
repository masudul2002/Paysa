import 'package:paysa/core/app_exception.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/repositories/recurring_repository.dart';
import '../datasources/recurring_local_datasource.dart';
import '../models/recurring_record.dart';

final class RecurringRepositoryImpl implements RecurringRepository {
  RecurringRepositoryImpl(this._ds);
  final RecurringLocalDataSource _ds;

  @override
  Future<RecurringTransaction> create(RecurringTransaction tpl) async {
    if (tpl.title.trim().isEmpty) throw AppException('Title is required.');
    if (tpl.amountMinor <= 0) throw AppException('Amount must be greater than zero.');
    final now = DateTime.now();
    final saved = await _ds.put(tpl.copyWith(
      status: RecurringStatus.draft,
      nextExecutionDate: tpl.startDate ?? now,
      createdAt: now, updatedAt: now, version: 1,
    ).toRecord());
    return saved.toEntity();
  }

  @override Future<RecurringTransaction> update(RecurringTransaction tpl) async {
    final existing = await _ds.getById(tpl.id);
    if (existing == null) throw AppException('Template not found.');
    final now = DateTime.now();
    final saved = await _ds.put(tpl.copyWith(updatedAt: now, version: existing.version + 1).toRecord());
    return saved.toEntity();
  }

  @override Future<void> delete(int id) async {
    final r = await _ds.getById(id);
    if (r == null) throw AppException('Template not found.');
    r.deletedAt = DateTime.now(); await _ds.put(r);
  }

  @override Future<RecurringTransaction?> getById(int id) async => (await _ds.getById(id))?.toEntity();

  @override Future<List<RecurringTransaction>> getAll({RecurringStatus? statusFilter}) async {
    var all = await _ds.getAll();
    all = all.where((r) => r.deletedAt == null).toList();
    if (statusFilter != null) all = all.where((r) => r.status == statusFilter.index).toList();
    all.sort((a, b) => (b.nextExecutionDate ?? b.createdAt).compareTo(a.nextExecutionDate ?? a.createdAt));
    return all.map((r) => r.toEntity()).toList();
  }

  @override Stream<List<RecurringTransaction>> watchAll() => _ds.watchAll().map((list) =>
    list.where((r) => r.deletedAt == null).map((r) => r.toEntity()).toList());

  @override Future<void> activate(int id) async {
    final r = await _ds.getById(id);
    if (r == null) throw AppException('Template not found.');
    r.status = RecurringStatus.active.index;
    r.updatedAt = DateTime.now();
    if (r.nextExecutionDate == null) r.nextExecutionDate = DateTime.now();
    await _ds.put(r);
  }

  @override Future<void> pause(int id) async {
    final r = await _ds.getById(id);
    if (r == null) throw AppException('Template not found.');
    r.status = RecurringStatus.paused.index; r.updatedAt = DateTime.now();
    await _ds.put(r);
  }

  @override Future<void> archive(int id) async {
    final r = await _ds.getById(id);
    if (r == null) throw AppException('Template not found.');
    r.status = RecurringStatus.archived.index; r.deletedAt = DateTime.now();
    await _ds.put(r);
  }

  @override Future<RecurringTransaction> duplicate(int id) async {
    final existing = await _ds.getById(id);
    if (existing == null) throw AppException('Template not found.');
    final now = DateTime.now();
    final copy = existing.toEntity().copyWith(
      id: 0, title: '${existing.title} (copy)',
      status: RecurringStatus.draft, executionCount: 0,
      nextExecutionDate: now, lastExecutionDate: null,
      createdAt: now, updatedAt: now, version: 1, deletedAt: null,
    ).toRecord();
    return (await _ds.put(copy)).toEntity();
  }

  @override Future<RecurringTransaction> execute(int id) async {
    final existing = await _ds.getById(id);
    if (existing == null) throw AppException('Template not found.');
    final now = DateTime.now();

    // Calculate next execution date
    final tpl = existing.toEntity();
    final nextDate = tpl.calculateNextDate(now);

    existing.lastExecutionDate = now;
    existing.executionCount = existing.executionCount + 1;
    existing.nextExecutionDate = nextDate;
    existing.updatedAt = now;

    // If end condition reached, mark completed
    if (nextDate == null) {
      existing.status = RecurringStatus.completed.index;
    }

    await _ds.put(existing);
    return existing.toEntity();
  }

  @override Future<List<RecurringTransaction>> getDue() async {
    final all = await _ds.getAll();
    final now = DateTime.now();
    return all.where((r) =>
      r.deletedAt == null && r.status == RecurringStatus.active.index &&
      r.nextExecutionDate != null && r.nextExecutionDate!.isBefore(now)
    ).map((r) => r.toEntity()).toList();
  }

  @override Future<List<RecurringTransaction>> getUpcoming() async {
    final all = await _ds.getAll();
    final now = DateTime.now();
    return all.where((r) =>
      r.deletedAt == null && r.status == RecurringStatus.active.index &&
      r.nextExecutionDate != null && r.nextExecutionDate!.isAfter(now)
    ).map((r) => r.toEntity()).toList();
  }
}
