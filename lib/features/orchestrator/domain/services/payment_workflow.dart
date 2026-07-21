/// Result of a workflow execution.
sealed class PaymentWorkflowResult {
  const PaymentWorkflowResult();
}

final class WorkflowSuccess extends PaymentWorkflowResult {
  const WorkflowSuccess({this.transactionId, this.ledgerEntryId});
  final String? transactionId;
  final int? ledgerEntryId;
}

final class WorkflowFailure extends PaymentWorkflowResult {
  const WorkflowFailure({required this.reason, this.failedStep});
  final String reason;
  final String? failedStep;
}

final class WorkflowRollback extends PaymentWorkflowResult {
  const WorkflowRollback({required this.originalFailure, required this.rollbackStep});
  final WorkflowFailure originalFailure;
  final String rollbackStep;
}
