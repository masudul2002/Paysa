import 'dart:io';

import 'package:isar/isar.dart';
import 'package:paysa/features/accounts/data/models/account_record.dart';
import 'package:paysa/features/categories/data/models/category_record.dart';
import 'package:paysa/features/people/data/models/person_record.dart';
import 'package:paysa/features/transactions/data/models/transaction_record.dart';

/// Creates a temporary Isar instance for testing.
///
/// Each test gets an isolated instance using a unique file path.
Future<Isar> createTestIsar() async {
  final dir = Directory.systemTemp.createTempSync('paysa_test_');

  return Isar.open(
    [
      AccountRecordSchema,
      CategoryRecordSchema,
      PersonRecordSchema,
      TransactionRecordSchema,
    ],
    directory: dir.path,
    name: 'test_${DateTime.now().microsecondsSinceEpoch}',
    inspector: false,
  );
}
