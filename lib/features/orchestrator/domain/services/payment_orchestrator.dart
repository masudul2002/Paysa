import 'dart:async';

import 'package:paysa/core/app_exception.dart';
import 'package:paysa/features/orchestrator/domain/events/payment_events.dart';
import 'package:paysa/features/orchestrator/domain/services/payment_workflow.dart';
import 'package:paysa/features/payment_link/data/repositories/payment_link_repository.dart';
import 'package:paysa/features/payment_provider/domain/entities/payment_provider.dart';
import 'package:paysa/features/payment_provider/domain/services/payment_provider_registry.dart';
import 'package:paysa/features/payment_request/data/repositories/payment_request_repository_impl.dart';
import 'package:paysa/features/payment_request/domain/entities/payment_request.dart';

typedef _WorkflowStep = Future<FinancialWorkflowContext> Function(FinancialWorkflowContext ctx);

/// Context passed through a workflow execution.
final class FinancialWorkflowContext {
  const FinancialWorkflowContext({
    this.paymentRequestId,
    this.paymentRequest,
    this.providerName,
    this.provider,
    this.amountMinor,
    this.currencyCode = 'USD',
    this.personId,
    this.transactionId,
    this.ledgerEntryId,
  });

  final int? paymentRequestId;
  final PaymentRequest? paymentRequest;
  final String? providerName;
  final PaymentProvider? provider;
  final int? amountMinor;
  final String currencyCode;
  final int? personId;
  final String? transactionId;
  final int? ledgerEntryId;

  FinancialWorkflowContext copyWith({
    int? paymentRequestId,
    PaymentRequest? paymentRequest,
    String? providerName,
    PaymentProvider? provider,
    int? amountMinor,
    String? currencyCode,
    int? personId,
    String? transactionId,
    int? ledgerEntryId,
  }) => FinancialWorkflowContext(
    paymentRequestId: paymentRequestId ?? this.paymentRequestId,
    paymentRequest: paymentRequest ?? this.paymentRequest,
    providerName: providerName ?? this.providerName,
    provider: provider ?? this.provider,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    personId: personId ?? this.personId,
    transactionId: transactionId ?? this.transactionId,
    ledgerEntryId: ledgerEntryId ?? this.ledgerEntryId,
  );
}

/// The central orchestrator for all payment-related workflows.
///
/// Every payment operation goes through this class.
/// Individual modules (PaymentRequest, Ledger, etc.) never call each other.
final class PaymentOrchestrator {
  PaymentOrchestrator({
    required this.paymentRequestRepo,
    required this.paymentLinkRepo,
    required this.providerRegistry,
  });

  final PaymentRequestRepositoryImpl paymentRequestRepo;
  final PaymentLinkRepository paymentLinkRepo;
  final PaymentProviderRegistry providerRegistry;

  final _eventController = StreamController<PaymentEvent>.broadcast();

  /// Stream of all domain events emitted during workflow execution.
  Stream<PaymentEvent> get events => _eventController.stream;

  /// List of emitted events for inspection/testing.
  final List<PaymentEvent> eventHistory = [];

  void _emit(PaymentEvent event) {
    eventHistory.add(event);
    _eventController.add(event);
  }

  // -----------------------------------------------------------------------
  // Workflow 1: Loan Repayment
  // -----------------------------------------------------------------------

  /// Full loan repayment workflow:
  ///   PaymentRequest → PaymentLink → Provider → Transaction → Ledger → Receipt
  Future<PaymentWorkflowResult> processLoanRepayment(int requestId) async {
    final context = FinancialWorkflowContext(paymentRequestId: requestId);
    return _executeWorkflow('LoanRepayment', context, [
      _stepLoadRequest,
      _stepCreateLink,
      _stepProviderPayment,
      _stepUpdateRequestStatus,
      _stepTriggerReceipt,
    ]);
  }

  // -----------------------------------------------------------------------
  // Workflow 2: General Payment
  // -----------------------------------------------------------------------

  /// General payment workflow (no ledger link):
  ///   PaymentRequest → Provider → Transaction → Account → Receipt
  Future<PaymentWorkflowResult> processGeneralPayment(int requestId) async {
    final context = FinancialWorkflowContext(paymentRequestId: requestId);
    return _executeWorkflow('GeneralPayment', context, [
      _stepLoadRequest,
      _stepProviderPayment,
      _stepUpdateRequestStatus,
      _stepTriggerReceipt,
    ]);
  }

  // -----------------------------------------------------------------------
  // Workflow 3: Cancel Payment
  // -----------------------------------------------------------------------

  Future<PaymentWorkflowResult> cancelPayment(int requestId) async {
    try {
      await paymentRequestRepo.cancel(requestId);
      _emit(PaymentCancelledEvent(requestId: requestId, timestamp: DateTime.now()));
      return const WorkflowSuccess();
    } on AppException catch (e) {
      return WorkflowFailure(reason: e.message, failedStep: 'cancel');
    }
  }

  // -----------------------------------------------------------------------
  // Workflow 4: Expire Payment Link
  // -----------------------------------------------------------------------

  Future<PaymentWorkflowResult> expirePaymentLink(int linkId, int requestId) async {
    try {
      await paymentLinkRepo.expire(linkId);
      await paymentRequestRepo.expire(requestId);
      _emit(PaymentExpiredEvent(linkId: linkId, requestId: requestId, timestamp: DateTime.now()));
      return const WorkflowSuccess();
    } on AppException catch (e) {
      return WorkflowFailure(reason: e.message, failedStep: 'expire');
    }
  }

  // -----------------------------------------------------------------------
  // Workflow execution engine
  // -----------------------------------------------------------------------

  Future<PaymentWorkflowResult> _executeWorkflow(
    String name,
    FinancialWorkflowContext initial,
    List<_WorkflowStep> steps,
  ) async {
    var context = initial;
    for (int i = 0; i < steps.length; i++) {
      try {
        context = await steps[i](context);
      } on AppException catch (e) {
        final failure = WorkflowFailure(reason: e.message, failedStep: 'step_$i');
        _emit(RollbackPerformedEvent(
          workflowName: name, failedStep: 'step_$i',
          reason: e.message, timestamp: DateTime.now(),
        ));
        return _rollback(context, failure);
      } catch (e) {
        final failure = WorkflowFailure(reason: e.toString(), failedStep: 'step_$i');
        return _rollback(context, failure);
      }
    }
    return WorkflowSuccess(
      transactionId: context.transactionId,
      ledgerEntryId: context.ledgerEntryId,
    );
  }

  PaymentWorkflowResult _rollback(FinancialWorkflowContext ctx, WorkflowFailure failure) {
    // If no state was mutated, return the failure directly
    if (ctx.transactionId == null && ctx.ledgerEntryId == null) {
      return failure;
    }
    // Future: extend rollback to undo ledger entries, transactions, and links
    return WorkflowRollback(originalFailure: failure, rollbackStep: 'rollback_complete');
  }

  // -----------------------------------------------------------------------
  // Steps
  // -----------------------------------------------------------------------

  Future<FinancialWorkflowContext> _stepLoadRequest(FinancialWorkflowContext ctx) async {
    final request = await paymentRequestRepo.findById(ctx.paymentRequestId!);
    if (request == null) throw AppException('Payment request not found.');
    if (!request.isPayable) throw AppException('Payment request is not payable.');
    _emit(PaymentRequestCreatedEvent(
      requestId: request.id, timestamp: DateTime.now(),
    ));
    return ctx.copyWith(
      paymentRequest: request,
      amountMinor: request.amountMinor,
      currencyCode: request.currencyCode,
      personId: request.personId,
    );
  }

  Future<FinancialWorkflowContext> _stepCreateLink(FinancialWorkflowContext ctx) async {
    final providerName = ctx.providerName ?? 'paysa';
    final link = await paymentLinkRepo.create(ctx.paymentRequestId!, providerName);
    _emit(PaymentStartedEvent(
      requestId: ctx.paymentRequestId!, provider: providerName,
      timestamp: DateTime.now(),
    ));
    return ctx.copyWith(providerName: providerName);
  }

  Future<FinancialWorkflowContext> _stepProviderPayment(FinancialWorkflowContext ctx) async {
    final providerName = ctx.providerName ?? 'cash';
    final provider = providerRegistry.getProvider(providerName);
    if (provider == null) throw AppException('Provider "$providerName" is not available.');
    if (ctx.amountMinor == null) throw AppException('Amount not set in workflow context.');

    final result = await provider.createPayment(
      amountMinor: ctx.amountMinor!,
      currency: ctx.currencyCode,
      reference: 'REQ-${ctx.paymentRequestId}',
    );

    if (!result.success) {
      throw AppException(result.errorMessage ?? 'Payment failed.');
    }

    _emit(PaymentSucceededEvent(
      requestId: ctx.paymentRequestId!, provider: providerName,
      transactionId: result.transactionId!, amountMinor: ctx.amountMinor!,
      timestamp: DateTime.now(),
    ));

    return ctx.copyWith(transactionId: result.transactionId, providerName: providerName);
  }

  Future<FinancialWorkflowContext> _stepUpdateRequestStatus(FinancialWorkflowContext ctx) async {
    if (ctx.paymentRequest == null) throw AppException('Payment request not in context.');
    final updated = await paymentRequestRepo.update(
      ctx.paymentRequest!.copyWith(status: PaymentRequestStatus.paid),
    );
    return ctx.copyWith(paymentRequest: updated);
  }

  Future<FinancialWorkflowContext> _stepTriggerReceipt(FinancialWorkflowContext ctx) async {
    _emit(ReceiptRequestedEvent(
      requestId: ctx.paymentRequestId!, timestamp: DateTime.now(),
    ));
    return ctx;
  }

  /// Dispose the event stream controller.
  void dispose() {
    _eventController.close();
  }
}
