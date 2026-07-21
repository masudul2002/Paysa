import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/app_providers.dart';
import '../../data/datasources/isar_budget_local_datasource.dart';
import '../../data/repositories/budget_repository_impl.dart';

final budgetRepositoryProvider = Provider((ref) {
  final isar = ref.watch(isarProvider);
  return BudgetRepositoryImpl(IsarBudgetLocalDataSource(isar));
});

final budgetListProvider = StreamProvider.autoDispose((ref) {
  return ref.watch(budgetRepositoryProvider).watchAll();
});

final budgetProgressProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(budgetRepositoryProvider).getProgress();
});
