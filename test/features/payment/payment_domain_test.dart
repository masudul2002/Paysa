import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/payment/domain/entities/payment_request.dart';
import 'package:paysa/features/payment/domain/entities/payment_receipt.dart';
import 'package:paysa/features/payment/domain/entities/payment_session.dart';

final _now = DateTime.now();

void main() {
  // ====================================================================
  // PaymentRequest
  // ====================================================================

  group('PaymentRequest', () {
    test('valid request passes validation', () {
      final r = PaymentRequest(
        uuid: 'abc-123',
        requestNumber: 'REQ-001',
        title: 'Club fee for July',
        requestType: PaymentRequestType.clubFee,
        amountMinor: 50000,
        createdAt: _now,
        updatedAt: _now,
      );
      expect(r.validate(), isNull);
    });

    test('invalid with zero amount', () {
      final r = PaymentRequest(
        uuid: 'abc', requestNumber: 'R1', title: 'T',
        requestType: PaymentRequestType.generalPayment,
        amountMinor: 0, createdAt: _now, updatedAt: _now,
      );
      expect(r.validate(), isNotNull);
    });

    test('invalid with negative amount', () {
      final r = PaymentRequest(
        uuid: 'abc', requestNumber: 'R1', title: 'T',
        requestType: PaymentRequestType.generalPayment,
        amountMinor: -100, createdAt: _now, updatedAt: _now,
      );
      expect(r.validate(), isNotNull);
    });

    test('default status is draft', () {
      final r = PaymentRequest(
        uuid: 'abc', requestNumber: 'R1', title: 'T',
        requestType: PaymentRequestType.donation,
        amountMinor: 1000, createdAt: _now, updatedAt: _now,
      );
      expect(r.status, PaymentStatus.draft);
    });

    test('isExpired when past expiresAt', () {
      final r = PaymentRequest(
        uuid: 'abc', requestNumber: 'R1', title: 'T',
        requestType: PaymentRequestType.invoice,
        amountMinor: 5000, expiresAt: _now.subtract(const Duration(days: 1)),
        createdAt: _now, updatedAt: _now,
      );
      expect(r.isExpired, true);
    });

    test('isPayable for draft, pending, partially paid', () {
      for (final s in [PaymentStatus.draft, PaymentStatus.pending, PaymentStatus.partiallyPaid]) {
        final r = PaymentRequest(
          uuid: 'abc', requestNumber: 'R1', title: 'T',
          requestType: PaymentRequestType.support,
          amountMinor: 1000, status: s,
          createdAt: _now, updatedAt: _now,
        );
        expect(r.isPayable, true, reason: 'status=${s.label}');
      }
    });

    test('not payable for terminal statuses', () {
      for (final s in [PaymentStatus.paid, PaymentStatus.expired, PaymentStatus.cancelled, PaymentStatus.failed]) {
        final r = PaymentRequest(
          uuid: 'abc', requestNumber: 'R1', title: 'T',
          requestType: PaymentRequestType.loanRepayment,
          amountMinor: 1000, status: s,
          createdAt: _now, updatedAt: _now,
        );
        expect(r.isPayable, false, reason: 'status=${s.label}');
      }
    });

    test('copyWith preserves unchanged fields', () {
      final r = PaymentRequest(
        uuid: 'abc', requestNumber: 'R1', title: 'Original',
        requestType: PaymentRequestType.generalPayment,
        amountMinor: 5000, createdAt: _now, updatedAt: _now,
      );
      final c = r.copyWith(title: 'Updated');
      expect(c.title, 'Updated');
      expect(c.amountMinor, 5000);
      expect(c.requestType, PaymentRequestType.generalPayment);
    });

    test('all 7 request types have labels', () {
      for (final t in PaymentRequestType.values) {
        expect(t.label.isNotEmpty, true);
      }
    });

    test('all 7 statuses have labels and correct terminal states', () {
      expect(PaymentStatus.values.length, 7);
      expect(PaymentStatus.paid.isTerminal, true);
      expect(PaymentStatus.expired.isTerminal, true);
      expect(PaymentStatus.cancelled.isTerminal, true);
      expect(PaymentStatus.failed.isTerminal, true);
      expect(PaymentStatus.draft.isTerminal, false);
      expect(PaymentStatus.pending.isTerminal, false);
      expect(PaymentStatus.partiallyPaid.isTerminal, false);
    });
  });

  // ====================================================================
  // PaymentReceipt
  // ====================================================================

  group('PaymentReceipt', () {
    test('valid receipt passes validation', () {
      final r = PaymentReceipt(
        uuid: 'rct-001',
        receiptNumber: 'RCT-2026-001',
        paymentRequestId: 1,
        payerName: 'Rafiq Ahmed',
        amountMinor: 50000,
        paidAt: _now,
      );
      expect(r.validate(), isNull);
    });

    test('invalid with zero amount', () {
      final r = PaymentReceipt(
        uuid: 'r', receiptNumber: 'R1', paymentRequestId: 1,
        payerName: 'P', amountMinor: 0, paidAt: _now,
      );
      expect(r.validate(), isNotNull);
    });

    test('all 9 payment method types', () {
      expect(PaymentMethodType.values.length, 9);
      for (final m in PaymentMethodType.values) {
        expect(m.label.isNotEmpty, true);
      }
    });

    test('copyWith works', () {
      final r = PaymentReceipt(
        uuid: 'r1', receiptNumber: 'R1', paymentRequestId: 1,
        payerName: 'Alice', amountMinor: 1000, paidAt: _now,
      );
      final c = r.copyWith(payerName: 'Bob', notes: 'Done');
      expect(c.payerName, 'Bob');
      expect(c.notes, 'Done');
      expect(c.amountMinor, 1000);
    });
  });

  // ====================================================================
  // PaymentSession
  // ====================================================================

  group('PaymentSession', () {
    test('valid session passes validation', () {
      final s = PaymentSession(
        uuid: 's-001', paymentRequestId: 1, amountMinor: 50000,
      );
      expect(s.validate(), isNull);
    });

    test('invalid with zero amount', () {
      final s = PaymentSession(
        uuid: 's-001', paymentRequestId: 1, amountMinor: 0,
      );
      expect(s.validate(), isNotNull);
    });

    test('terminal statuses', () {
      expect(PaymentSessionStatus.succeeded.isTerminal, true);
      expect(PaymentSessionStatus.failed.isTerminal, true);
      expect(PaymentSessionStatus.cancelled.isTerminal, true);
      expect(PaymentSessionStatus.initiated.isTerminal, false);
      expect(PaymentSessionStatus.processing.isTerminal, false);
    });

    test('isSuccess on succeeded', () {
      final s = PaymentSession(
        uuid: 's1', paymentRequestId: 1, amountMinor: 1000,
        status: PaymentSessionStatus.succeeded,
      );
      expect(s.isSuccess, true);
    });

    test('all 9 provider types have labels', () {
      expect(PaymentProviderType.values.length, 9);
      for (final p in PaymentProviderType.values) {
        expect(p.label.isNotEmpty, true);
      }
    });

    test('copyWith works', () {
      final s = PaymentSession(
        uuid: 's1', paymentRequestId: 1, amountMinor: 5000,
      );
      final c = s.copyWith(status: PaymentSessionStatus.failed, failureReason: 'Timeout');
      expect(c.status, PaymentSessionStatus.failed);
      expect(c.failureReason, 'Timeout');
    });
  });
}
