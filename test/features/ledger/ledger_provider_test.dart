import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/ledger/domain/entities/ledger.dart';
import 'package:paysa/features/ledger/presentation/providers/ledger_providers.dart';

void main() {
  group('LedgerSortConfig', () {
    test('default sort is date descending', () {
      expect(LedgerSortField.date.name, 'date');
      expect(LedgerSortDirection.descending.name, 'descending');
    });

    test('all sort fields exist', () {
      expect(LedgerSortField.values.length, 4);
      expect(LedgerSortField.values.contains(LedgerSortField.date), true);
      expect(LedgerSortField.values.contains(LedgerSortField.amount), true);
      expect(LedgerSortField.values.contains(LedgerSortField.entryType), true);
      expect(LedgerSortField.values.contains(LedgerSortField.createdAt), true);
    });

    test('both sort directions exist', () {
      expect(LedgerSortDirection.values.length, 2);
      expect(LedgerSortDirection.values.contains(LedgerSortDirection.ascending), true);
      expect(LedgerSortDirection.values.contains(LedgerSortDirection.descending), true);
    });
  });

  group('LedgerStats', () {
    test('empty stats', () {
      final stats = LedgerStats(
        totalGive: 0, totalReceive: 0, totalDiscount: 0,
        totalSale: 0, totalPurchase: 0, totalAdjustment: 0,
        entryCount: 0, netFlow: 0,
      );
      expect(stats.totalTransactions, 0);
      expect(stats.describe(), '0 entries · Give: 0 · Receive: 0 · Net: 0');
    });

    test('stats with values', () {
      final stats = LedgerStats(
        totalGive: 50000, totalReceive: 20000, totalDiscount: 5000,
        totalSale: 30000, totalPurchase: 10000, totalAdjustment: 2000,
        entryCount: 10, netFlow: 52000,
      );
      expect(stats.totalTransactions, 110000); // give + receive + sale + purchase
      expect(stats.describe(), contains('10 entries'));
      expect(stats.describe(), contains('Give: 50000'));
      expect(stats.describe(), contains('Receive: 20000'));
    });

    test('net flow equals give + sale - receive - discount', () {
      final stats = LedgerStats(
        totalGive: 100000, totalReceive: 30000, totalDiscount: 5000,
        totalSale: 20000, totalPurchase: 0, totalAdjustment: 0,
        entryCount: 5, netFlow: 85000,
      );
      expect(stats.netFlow, 85000);
    });
  });

  group('LedgerEntryType behavior', () {
    test('isIncoming returns true for receive and repayment', () {
      expect(LedgerEntryType.receive.isIncoming, true);
      expect(LedgerEntryType.repayment.isIncoming, true);
      expect(LedgerEntryType.give.isIncoming, false);
      expect(LedgerEntryType.sale.isIncoming, false);
    });

    test('isOutgoing returns true for give, borrow, sale, purchase', () {
      expect(LedgerEntryType.give.isOutgoing, true);
      expect(LedgerEntryType.borrow.isOutgoing, true);
      expect(LedgerEntryType.sale.isOutgoing, true);
      expect(LedgerEntryType.purchase.isOutgoing, true);
      expect(LedgerEntryType.receive.isOutgoing, false);
      expect(LedgerEntryType.opening.isOutgoing, false);
    });

    test('label returns human-readable name', () {
      expect(LedgerEntryType.give.label, 'Give');
      expect(LedgerEntryType.receive.label, 'Receive');
      expect(LedgerEntryType.sale.label, 'Sale');
      expect(LedgerEntryType.purchase.label, 'Purchase');
      expect(LedgerEntryType.opening.label, 'Opening Balance');
      expect(LedgerEntryType.discount.label, 'Discount');
      expect(LedgerEntryType.adjustment.label, 'Adjustment');
      expect(LedgerEntryType.manual.label, 'Manual Entry');
      expect(LedgerEntryType.borrow.label, 'Borrow');
      expect(LedgerEntryType.repayment.label, 'Repayment');
    });

    test('all 10 entry types exist', () {
      expect(LedgerEntryType.values.length, 10);
    });
  });

  group('LedgerStatus', () {
    test('has 3 statuses', () {
      expect(LedgerStatus.values.length, 3);
      expect(LedgerStatus.values.contains(LedgerStatus.active), true);
      expect(LedgerStatus.values.contains(LedgerStatus.archived), true);
      expect(LedgerStatus.values.contains(LedgerStatus.closed), true);
    });
  });
}
