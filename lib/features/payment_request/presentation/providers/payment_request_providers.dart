import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

import '../../../../app/providers/app_providers.dart';
import '../../data/datasources/isar_payment_request_local_datasource.dart';
import '../../data/repositories/payment_request_repository_impl.dart';
import '../../domain/entities/payment_request.dart';

final paymentRequestRepositoryProvider = Provider((ref) {
  final isar = ref.watch(isarProvider);
  return PaymentRequestRepositoryImpl(IsarPaymentRequestLocalDataSource(isar));
});

final prStatusFilterProvider = StateProvider<PaymentRequestStatus?>((_) => null);
final prSearchProvider = StateProvider<String>((_) => '');

final prListProvider = StreamProvider.autoDispose<List<PaymentRequest>>((ref) {
  final repo = ref.watch(paymentRequestRepositoryProvider);
  final status = ref.watch(prStatusFilterProvider);
  final query = ref.watch(prSearchProvider);
  return repo.watchAll().map((list) {
    var filtered = list.toList();
    if (status != null) filtered = filtered.where((r) => r.status == status).toList();
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) filtered = filtered.where((r) => r.title.toLowerCase().contains(q) || r.requestNumber.toLowerCase().contains(q)).toList();
    return filtered;
  });
});

final prPendingProvider = Provider.autoDispose<Future<List<PaymentRequest>>>((ref) {
  return ref.watch(paymentRequestRepositoryProvider).getAll(statusFilter: PaymentRequestStatus.pending);
});

final prPaidProvider = Provider.autoDispose<Future<List<PaymentRequest>>>((ref) {
  return ref.watch(paymentRequestRepositoryProvider).getAll(statusFilter: PaymentRequestStatus.paid);
});

final prExpiredProvider = Provider.autoDispose<Future<List<PaymentRequest>>>((ref) {
  return ref.watch(paymentRequestRepositoryProvider).getAll(statusFilter: PaymentRequestStatus.expired);
});
