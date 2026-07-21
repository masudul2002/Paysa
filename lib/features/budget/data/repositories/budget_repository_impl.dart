import 'package:paysa/core/app_exception.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../models/budget_record.dart';

final class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._ds);
  final BudgetLocalDataSource _ds;

  @override
  Future<Budget> create(Budget b) async {
    if (b.name.trim().isEmpty) throw AppException('Budget name is required.');
    if (b.budgetAmountMinor <= 0) throw AppException('Budget amount must be greater than zero.');
    if (b.endDate.isBefore(b.startDate)) throw AppException('End date must be after start date.');

    final now = DateTime.now();
    final saved = await _ds.put(b.copyWith(
      status: BudgetStatus.safe, createdAt: now, updatedAt: now, version: 1,
    ).toRecord());
    return saved.toEntity();
  }

  @override
  Future<Budget> update(Budget b) async {
    final existing = await _ds.getById(b.id);
    if (existing == null) throw AppException('Budget not found.');
    final now = DateTime.now();
    final saved = await _ds.put(b.copyWith(updatedAt: now, version: existing.version + 1).toRecord());
    return saved.toEntity();
  }

  @override
  Future<void> archive(int id) async {
    final r = await _ds.getById(id);
    if (r == null) throw AppException('Budget not found.');
    r.archivedAt = DateTime.now(); r.status = BudgetStatus.archived.index;
    await _ds.put(r);
  }

  @override
  Future<void> delete(int id) async {
    final r = await _ds.getById(id);
    if (r == null) throw AppException('Budget not found.');
    await _ds.delete(id);
  }

  @override
  Future<Budget?> getById(int id) async => (await _ds.getById(id))?.toEntity();

  @override
  Future<List<Budget>> getAll({BudgetStatus? statusFilter, int? categoryId}) async {
    var all = await _ds.getAll();
    if (statusFilter != null) all = all.where((r) => r.status == statusFilter.index).toList();
    if (categoryId != null) all = all.where((r) => r.categoryId == categoryId).toList();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all.map((r) => r.toEntity()).toList();
  }

  @override
  Stream<List<Budget>> watchAll() => _ds.watchAll().map((l) => l.map((r) => r.toEntity()).toList());

  @override
  Future<BudgetProgress> getProgress() async {
    final all = await _ds.getAll();
    final active = all.where((r) => r.archivedAt == null).toList();
    int totalBudgeted = 0, totalSpent = 0, onTrack = 0, warning = 0, exceeded = 0;
    for (final b in active) {
      totalBudgeted += b.budgetAmountMinor;
      totalSpent += b.spentAmountMinor;
      final e = b.toEntity();
      if (e.isOnTrack) onTrack++; else exceeded++;
      if (e.isExceeded) exceeded++;
    }
    return BudgetProgress(
      totalBudgets: active.length, totalBudgeted: totalBudgeted,
      totalSpent: totalSpent, remaining: totalBudgeted - totalSpent,
      onTrack: onTrack, warning: warning, exceeded: exceeded,
    );
  }
}
