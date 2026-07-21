import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/accounts/data/models/account_record.dart';
import '../../features/categories/data/models/category_record.dart';
import '../../features/ledger/data/models/ledger_record.dart';
import '../../features/payment_link/data/models/payment_link_record.dart';
import '../../features/payment_request/data/models/payment_request_record.dart';
import '../../features/notification/data/models/notification_record.dart';
import '../../features/goal/data/models/goal_record.dart';
import '../../features/budget/data/models/budget_record.dart';
import '../../features/recurring/data/models/recurring_record.dart';
import '../../features/receipt/data/models/receipt_record.dart';
import '../../features/people/data/models/person_record.dart';
import '../../features/transactions/data/models/transaction_record.dart';

final class PaysaDatabase {
  const PaysaDatabase._();

  static const name = 'paysa';

  static Future<Isar> open() async {
    final directory = await getApplicationDocumentsDirectory();

    return Isar.open(
      [
        AccountRecordSchema,
        CategoryRecordSchema,
        LedgerRecordSchema,
        LedgerEntryRecordSchema,
        PaymentLinkRecordSchema,
        PaymentRequestRecordSchema,
        RecurringRecordSchema,
        ReceiptRecordSchema,
        GoalRecordSchema,
        NotificationRecordSchema,
        BudgetRecordSchema,
        AuditEntryRecordSchema,
        PersonRecordSchema,
        TransactionRecordSchema,
      ],
      directory: directory.path,
      name: name,
    );
  }
}
