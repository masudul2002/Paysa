import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

import '../../domain/services/payment_workflow.dart';
import '../../../../app/providers/app_providers.dart';
import '../../../payment_link/data/datasources/isar_payment_link_local_datasource.dart';
import '../../../payment_link/data/repositories/payment_link_repository_impl.dart';
import '../../../payment_provider/domain/services/payment_provider_registry.dart';
import '../../../payment_provider/domain/services/default_provider_factories.dart';
import '../../../payment_provider/presentation/providers/payment_provider_providers.dart';
import '../../../payment_request/data/datasources/isar_payment_request_local_datasource.dart';
import '../../../payment_request/data/repositories/payment_request_repository_impl.dart';
import '../../domain/services/payment_orchestrator.dart';

final paymentOrchestratorProvider = Provider<PaymentOrchestrator>((ref) {
  final isar = ref.watch(isarProvider);

  final paymentRequestRepo = PaymentRequestRepositoryImpl(
    IsarPaymentRequestLocalDataSource(isar),
  );
  final paymentLinkRepo = PaymentLinkRepositoryImpl(
    IsarPaymentLinkLocalDataSource(isar),
  );
  final providerRegistry = ref.watch(paymentProviderRegistryProvider);

  return PaymentOrchestrator(
    paymentRequestRepo: paymentRequestRepo,
    paymentLinkRepo: paymentLinkRepo,
    providerRegistry: providerRegistry,
  );
});

final orchestratorEventHistoryProvider = Provider<List>((ref) {
  final orchestrator = ref.watch(paymentOrchestratorProvider);
  return orchestrator.eventHistory;
});

final lastWorkflowResultProvider = StateProvider<PaymentWorkflowResult?>((ref) => null);
