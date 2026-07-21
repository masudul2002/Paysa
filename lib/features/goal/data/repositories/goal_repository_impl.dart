import 'package:paysa/core/app_exception.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_datasource.dart';
import '../models/goal_record.dart';

final class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this._ds);
  final GoalLocalDataSource _ds;

  @override Future<FinancialGoal> create(FinancialGoal g) async {
    if (g.title.trim().isEmpty) throw AppException('Goal title is required.');
    if (g.targetAmountMinor <= 0) throw AppException('Target amount must be greater than zero.');
    final now = DateTime.now();
    return (await _ds.put(g.copyWith(status: GoalStatus.notStarted, createdAt: now, updatedAt: now, version: 1).toRecord())).toEntity();
  }

  @override Future<FinancialGoal> update(FinancialGoal g) async {
    final e = await _ds.getById(g.id);
    if (e == null) throw AppException('Goal not found.');
    return (await _ds.put(g.copyWith(updatedAt: DateTime.now(), version: e.version + 1).toRecord())).toEntity();
  }

  @override Future<void> archive(int id) async {
    final r = await _ds.getById(id);
    if (r == null) throw AppException('Goal not found.');
    r.archivedAt = DateTime.now(); r.status = GoalStatus.archived.index; await _ds.put(r);
  }

  @override Future<FinancialGoal> contribute(int goalId, int amountMinor, {int? accountId, String? notes}) async {
    final r = await _ds.getById(goalId);
    if (r == null) throw AppException('Goal not found.');
    if (amountMinor <= 0) throw AppException('Contribution must be greater than zero.');
    r.currentAmountMinor += amountMinor;
    if (r.currentAmountMinor >= r.targetAmountMinor) r.status = GoalStatus.completed.index;
    else r.status = GoalStatus.onTrack.index;
    r.updatedAt = DateTime.now();
    return (await _ds.put(r)).toEntity();
  }

  @override Future<FinancialGoal?> getById(int id) async => (await _ds.getById(id))?.toEntity();

  @override Future<List<FinancialGoal>> getAll({GoalStatus? statusFilter}) async {
    var all = await _ds.getAll();
    if (statusFilter != null) all = all.where((r) => r.status == statusFilter.index).toList();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all.map((r) => r.toEntity()).toList();
  }

  @override Stream<List<FinancialGoal>> watchAll() => _ds.watchAll().map((l) => l.map((r) => r.toEntity()).toList());

  @override Future<GoalSummary> getSummary() async {
    final all = await _ds.getAll();
    final active = all.where((r) => r.archivedAt == null).toList();
    return GoalSummary(
      totalGoals: active.length,
      totalTarget: active.fold(0, (s, r) => s + r.targetAmountMinor),
      totalCurrent: active.fold(0, (s, r) => s + r.currentAmountMinor),
      completedCount: active.where((r) => r.status == GoalStatus.completed.index).length,
      behindCount: active.where((r) => r.status == GoalStatus.behind.index || r.toEntity().isBehind).length,
    );
  }
}
