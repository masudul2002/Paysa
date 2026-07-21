import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/core/app_exception.dart';
import 'package:paysa/features/orchestrator/domain/events/payment_events.dart';
import 'package:paysa/features/orchestrator/domain/services/payment_orchestrator.dart';
import 'package:paysa/features/orchestrator/domain/services/payment_workflow.dart';
import 'package:paysa/features/payment_link/data/datasources/payment_link_local_datasource.dart';
import 'package:paysa/features/payment_link/data/models/payment_link_record.dart';
import 'package:paysa/features/payment_link/data/repositories/payment_link_repository_impl.dart';
import 'package:paysa/features/payment_provider/domain/entities/payment_provider.dart';
import 'package:paysa/features/payment_provider/domain/services/payment_provider_registry.dart';
import 'package:paysa/features/payment_provider/domain/services/default_provider_factories.dart';
import 'package:paysa/features/payment_request/data/datasources/payment_request_local_datasource.dart';
import 'package:paysa/features/payment_request/data/models/payment_request_record.dart';
import 'package:paysa/features/payment_request/data/repositories/payment_request_repository_impl.dart';
import 'package:paysa/features/payment_request/domain/entities/payment_request.dart';

// ---------------------------------------------------------------------------
// In-memory datasources
// ---------------------------------------------------------------------------

class _InMemoryPRDS implements PaymentRequestLocalDataSource {
  final _records = <int, PaymentRequestRecord>{}; int _next = 1;
  @override Future<PaymentRequestRecord> put(PaymentRequestRecord r) async {
    if (r.id == 0) r.id = _next++; if (r.uuid.isEmpty) r.uuid = 'pr-${r.id}'; _records[r.id] = r; return r;
  }
  @override Future<PaymentRequestRecord?> getById(int id) async => _records[id];
  @override Future<PaymentRequestRecord?> getByRequestNumber(String n) async {
    for (final r in _records.values) { if (r.requestNumber == n && r.deletedAt == null) return r; } return null;
  }
  @override Future<List<PaymentRequestRecord>> getAll() async => _records.values.toList();
  @override Stream<List<PaymentRequestRecord>> watchAll() async* { yield _records.values.toList(); }
  @override Future<void> delete(int id) async { _records.remove(id); }
}

class _InMemoryPLDS implements PaymentLinkLocalDataSource {
  final _records = <int, PaymentLinkRecord>{}; int _next = 1;
  @override Future<PaymentLinkRecord> put(PaymentLinkRecord r) async {
    if (r.id == 0) r.id = _next++; if (r.uuid.isEmpty) r.uuid = 'pl-${r.id}'; _records[r.id] = r; return r;
  }
  @override Future<PaymentLinkRecord?> getById(int id) async => _records[id];
  @override Future<PaymentLinkRecord?> getByToken(String t) async {
    for (final r in _records.values) { if (r.token == t && r.deletedAt == null) return r; } return null;
  }
  @override Future<PaymentLinkRecord?> getByShortCode(String c) async {
    for (final r in _records.values) { if (r.shortCode == c && r.deletedAt == null) return r; } return null;
  }
  @override Future<List<PaymentLinkRecord>> getByPaymentRequest(int pid) async {
    return _records.values.where((r) => r.paymentRequestId == pid && r.deletedAt == null).toList();
  }
  @override Future<List<PaymentLinkRecord>> getAll() async => _records.values.toList();
  @override Stream<List<PaymentLinkRecord>> watchAll() async* { yield _records.values.toList(); }
  @override Future<void> delete(int id) async { _records.remove(id); }
}

final _now = DateTime.now();

PaymentRequest _req({int amount = 50000, PaymentRequestStatus status = PaymentRequestStatus.draft}) =>
    PaymentRequest(title: 'Test', amountMinor: amount, requestType: PaymentRequestType.generalPayment,
      status: status, createdAt: _now, updatedAt: _now);

void main() {
  late PaymentOrchestrator orchestrator;
  late PaymentRequestRepositoryImpl reqRepo;
  late PaymentLinkRepositoryImpl linkRepo;
  late PaymentProviderRegistry providerReg;

  setUp(() {
    reqRepo = PaymentRequestRepositoryImpl(_InMemoryPRDS());
    linkRepo = PaymentLinkRepositoryImpl(_InMemoryPLDS());
    providerReg = PaymentProviderRegistry();
    providerReg.register(CashPlaceholderProvider());
    orchestrator = PaymentOrchestrator(
      paymentRequestRepo: reqRepo,
      paymentLinkRepo: linkRepo,
      providerRegistry: providerReg,
    );
  });

  // ====================================================================
  // General Payment Workflow
  // ====================================================================

  group('processGeneralPayment', () {
    test('succeeds for valid request', () async {
      final req = _req(amount: 50000);
      final created = await reqRepo.create(req);
      final loaded = await reqRepo.findById(created.id);
      expect(loaded?.amountMinor, 50000, reason: 'amountMinor should persist through create');
      final result = await orchestrator.processGeneralPayment(created.id);
      if (result is WorkflowFailure) {
        final rf = result;
        fail('Expected success but got failure: ${rf.reason} (step: ${rf.failedStep})');
      }
      expect(result, isA<WorkflowSuccess>());
    });

    test('fails for missing request', () async {
      final result = await orchestrator.processGeneralPayment(999);
      expect(result, isA<WorkflowFailure>());
    });

    test('fails for unpaid request', () async {
      final r = await reqRepo.create(_req());
      await reqRepo.cancel(r.id);
      final result = await orchestrator.processGeneralPayment(r.id);
      expect(result, isA<WorkflowFailure>());
    });
  });

  // ====================================================================
  // Cancel Payment Workflow
  // ====================================================================

  group('cancelPayment', () {
    test('cancels a pending request', () async {
      final r = await reqRepo.create(_req());
      final result = await orchestrator.cancelPayment(r.id);
      expect(result, isA<WorkflowSuccess>());
      final updated = await reqRepo.findById(r.id);
      expect(updated?.status, PaymentRequestStatus.cancelled);
    });
  });

  // ====================================================================
  // Expire Payment Link Workflow
  // ====================================================================

  group('expirePaymentLink', () {
    test('expires link and request', () async {
      final r = await reqRepo.create(_req());
      final link = await linkRepo.create(r.id, 'paysa');
      final result = await orchestrator.expirePaymentLink(link.id, r.id);
      expect(result, isA<WorkflowSuccess>());
    });
  });

  // ====================================================================
  // Events
  // ====================================================================

  group('events', () {
    test('emits PaymentSucceededEvent on success', () async {
      final r = await reqRepo.create(_req());
      await orchestrator.processGeneralPayment(r.id);
      expect(orchestrator.eventHistory.any((e) => e is PaymentSucceededEvent), true);
    });

    test('emits PaymentRequestCreatedEvent', () async {
      final r = await reqRepo.create(_req());
      await orchestrator.processGeneralPayment(r.id);
      expect(orchestrator.eventHistory.any((e) => e is PaymentRequestCreatedEvent), true);
    });

    test('emits RollbackPerformedEvent on failure', () async {
      final result = await orchestrator.processGeneralPayment(999);
      expect(result, isA<WorkflowFailure>());
      expect(orchestrator.eventHistory.any((e) => e is RollbackPerformedEvent), true);
    });

    test('emits PaymentCancelledEvent', () async {
      final r = await reqRepo.create(_req());
      await orchestrator.cancelPayment(r.id);
      expect(orchestrator.eventHistory.any((e) => e is PaymentCancelledEvent), true);
    });

    test('emits PaymentExpiredEvent', () async {
      final r = await reqRepo.create(_req());
      final link = await linkRepo.create(r.id, 'paysa');
      await orchestrator.expirePaymentLink(link.id, r.id);
      expect(orchestrator.eventHistory.any((e) => e is PaymentExpiredEvent), true);
    });

    test('stream broadcasts events', () async {
      final events = <PaymentEvent>[];
      final sub = orchestrator.events.listen(events.add);
      final r = await reqRepo.create(_req());
      await orchestrator.processGeneralPayment(r.id);
      await Future(() {});
      expect(events.isNotEmpty, true);
      sub.cancel();
    });
  });

  // ====================================================================
  // Workflow results
  // ====================================================================

  group('workflow results', () {
    test('WorkflowSuccess has correct type', () {
      final s = WorkflowSuccess(transactionId: 'txn_1');
      expect(s, isA<PaymentWorkflowResult>());
    });

    test('WorkflowFailure has reason', () {
      final f = WorkflowFailure(reason: 'error', failedStep: 'step');
      expect(f.reason, 'error');
    });

    test('WorkflowRollback wraps original failure', () {
      final f = WorkflowFailure(reason: 'failed');
      final r = WorkflowRollback(originalFailure: f, rollbackStep: 'rb');
      expect(r.originalFailure.reason, 'failed');
    });
  });

  // ====================================================================
  // Context
  // ====================================================================

  group('FinancialWorkflowContext', () {
    test('copyWith preserves fields', () {
      final c = FinancialWorkflowContext(amountMinor: 1000);
      final copy = c.copyWith(amountMinor: 2000);
      expect(copy.amountMinor, 2000);
    });
  });
}
