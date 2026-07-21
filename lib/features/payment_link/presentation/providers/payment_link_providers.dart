import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

import '../../../../app/providers/app_providers.dart';
import '../../data/datasources/isar_payment_link_local_datasource.dart';
import '../../data/repositories/payment_link_repository_impl.dart';
import '../../data/services/default_payment_link_generator.dart';
import '../../domain/entities/payment_link.dart';
import '../../domain/services/payment_link_service.dart';
import '../../data/repositories/payment_link_repository.dart';

final paymentLinkRepositoryProvider = Provider<PaymentLinkRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return PaymentLinkRepositoryImpl(IsarPaymentLinkLocalDataSource(isar));
});

final paymentLinkServiceProvider = Provider<PaymentLinkService>((ref) {
  final repo = ref.watch(paymentLinkRepositoryProvider);
  final generator = DefaultPaymentLinkGenerator(repo);
  final validator = const DefaultPaymentLinkValidator();
  final resolver = DefaultPaymentLinkResolver(repo);
  return PaymentLinkService(
    generators: {generator.providerName: generator},
    resolver: resolver,
    validator: validator,
  );
});

final paymentLinkListProvider = StreamProvider.autoDispose<List<PaymentLink>>((ref) {
  return ref.watch(paymentLinkRepositoryProvider).watchAll();
});

final paymentLinksByRequestProvider = FutureProvider.autoDispose.family<List<PaymentLink>, int>((ref, requestId) {
  return ref.watch(paymentLinkRepositoryProvider).getByPaymentRequest(requestId);
});

final paymentLinkActiveProvider = FutureProvider.autoDispose.family<List<PaymentLink>, int>((ref, requestId) {
  return ref.watch(paymentLinkRepositoryProvider).getActiveLinks(requestId);
});
