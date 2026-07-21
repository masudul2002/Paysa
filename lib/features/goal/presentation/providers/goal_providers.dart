import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/app_providers.dart';
import '../../data/datasources/isar_goal_local_datasource.dart';
import '../../data/repositories/goal_repository_impl.dart';

final goalRepositoryProvider = Provider((ref) {
  final isar = ref.watch(isarProvider);
  return GoalRepositoryImpl(IsarGoalLocalDataSource(isar));
});

final goalListProvider = StreamProvider.autoDispose((ref) {
  return ref.watch(goalRepositoryProvider).watchAll();
});

final goalSummaryProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(goalRepositoryProvider).getSummary();
});
