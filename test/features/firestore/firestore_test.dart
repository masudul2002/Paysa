import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/firestore/domain/collections.dart';
import 'package:paysa/features/firestore/data/datasources/firestore_base_datasource.dart';
import 'package:paysa/features/firestore/data/datasources/firestore_account_datasource.dart';
import 'package:paysa/features/firestore/data/mappers/firestore_mappers.dart';

void main() {
  group('FirestoreCollections', () {
    test('has all expected collections', () {
      expect(FirestoreCollections.all.length, 11);
      expect(FirestoreCollections.accounts, 'accounts');
      expect(FirestoreCollections.transactions, 'transactions');
      expect(FirestoreCollections.people, 'people');
    });
  });

  group('FirestoreBaseDataSource', () {
    test('upsert and getById', () async {
      final ds = FirestoreAccountDatasource();
      await ds.upsert('accounts', 'acc1', {'name': 'Bank', 'balance': 50000});
      final doc = await ds.getById('accounts', 'acc1');
      expect(doc?['name'], 'Bank');
      expect(doc?['updatedAt'], isNotNull);
    });

    test('getAll returns all documents', () async {
      final ds = FirestoreAccountDatasource();
      await ds.upsert('accounts', 'a1', {'name': 'A'});
      await ds.upsert('accounts', 'a2', {'name': 'B'});
      expect((await ds.getAll('accounts')).length, 2);
    });

    test('delete removes document', () async {
      final ds = FirestoreAccountDatasource();
      await ds.upsert('accounts', 'del1', {'name': 'Delete Me'});
      await ds.delete('accounts', 'del1');
      expect(await ds.getById('accounts', 'del1'), isNull);
    });

    test('returns null for missing document', () async {
      final ds = FirestoreAccountDatasource();
      expect(await ds.getById('accounts', 'nonexistent'), isNull);
    });
  });

  group('FirestoreAccountDatasource', () {
    test('upsertAccount and getAccount', () async {
      final ds = FirestoreAccountDatasource();
      await ds.upsertAccount('acc1', {'name': 'Savings', 'balance': 100000});
      final doc = await ds.getAccount('acc1');
      expect(doc?['name'], 'Savings');
      expect(doc?['version'], 1);
    });

    test('deleteAccount removes', () async {
      final ds = FirestoreAccountDatasource();
      await ds.upsertAccount('acc1', {'name': 'Temp'});
      await ds.deleteAccount('acc1');
      expect(await ds.getAccount('acc1'), isNull);
    });
  });

  group('FirestoreTransactionDatasource', () {
    test('upsertTransaction and getAllTransactions', () async {
      final ds = FirestoreTransactionDatasource();
      await ds.upsertTransaction('tx1', {'type': 'income', 'amount': 50000});
      await ds.upsertTransaction('tx2', {'type': 'expense', 'amount': 15000});
      expect((await ds.getAllTransactions()).length, 2);
    });
  });

  group('FirestoreMapper', () {
    test('listFromFirestore converts documents', () {
      final mapper = _TestMapper();
      final docs = [
        {'id': '1', 'name': 'Alice'},
        {'id': '2', 'name': 'Bob'},
      ];
      final results = mapper.listFromFirestore(docs);
      expect(results.length, 2);
      expect(results.first, 'Alice');
    });
  });

  group('TimestampMixin', () {
    test('addTimestamps adds version and timestamps', () {
      final mixin = _TestWithTimestamp();
      final data = mixin.addTimestamps({'name': 'Test'});
      expect(data['version'], 1);
      expect(data['createdAt'], isNotNull);
      expect(data['updatedAt'], isNotNull);
    });
  });
}

class _TestMapper extends FirestoreMapper<String> {
  @override Map<String, dynamic> toFirestore(String entity) => {'name': entity};
  @override String fromFirestore(Map<String, dynamic> data, String id) => data['name'] as String? ?? '';
}

class _TestWithTimestamp with TimestampMixin {}
