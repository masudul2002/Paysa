import '../../domain/collections.dart';
import '../mappers/firestore_mappers.dart';
import 'firestore_base_datasource.dart';

/// Firestore datasource for Account records.
final class FirestoreAccountDatasource extends FirestoreBaseDataSource {
  final _collection = FirestoreCollections.accounts;
  final _mapper = _AccountMapper();

  Future<List<Map<String, dynamic>>> getAllAccounts() => getAll(_collection);
  Future<Map<String, dynamic>?> getAccount(String id) => getById(_collection, id);
  Future<void> upsertAccount(String id, Map<String, dynamic> data) => upsert(_collection, id, _mapper.toFirestore(data));
  Future<void> deleteAccount(String id) => delete(_collection, id);
}

final class _AccountMapper with TimestampMixin {
  Map<String, dynamic> toFirestore(Map<String, dynamic> data) => addTimestamps(data);
}

/// Firestore datasource for Transaction records.
final class FirestoreTransactionDatasource extends FirestoreBaseDataSource {
  final _collection = FirestoreCollections.transactions;

  Future<List<Map<String, dynamic>>> getAllTransactions() => getAll(_collection);
  Future<Map<String, dynamic>?> getTransaction(String id) => getById(_collection, id);
  Future<void> upsertTransaction(String id, Map<String, dynamic> data) => upsert(_collection, id, data);
  Future<void> deleteTransaction(String id) => delete(_collection, id);
}
