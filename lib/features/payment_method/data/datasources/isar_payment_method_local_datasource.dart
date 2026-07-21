import 'package:isar/isar.dart';

import '../models/payment_method_record.dart';
import 'payment_method_local_datasource.dart';

final class IsarPaymentMethodLocalDataSource implements PaymentMethodLocalDataSource {
  const IsarPaymentMethodLocalDataSource(this._isar);

  final Isar _isar;

  IsarCollection<PaymentMethodRecord> get _collection =>
      _isar.collection<PaymentMethodRecord>();

  @override
  Future<PaymentMethodRecord> put(PaymentMethodRecord record) async {
    final id = await _isar.writeTxn(() => _collection.put(record));
    final saved = await _collection.get(id);
    if (saved == null) throw Exception('Failed to save payment method.');
    return saved;
  }

  @override
  Future<PaymentMethodRecord?> getById(int id) => _collection.get(id);

  @override
  Future<List<PaymentMethodRecord>> getAll() async {
    return _collection.where().findAll();
  }

  @override
  Stream<List<PaymentMethodRecord>> watchAll() {
    return _collection.watchLazy(fireImmediately: true).asyncMap((_) => getAll());
  }

  @override
  Future<void> delete(int id) {
    return _isar.writeTxn(() => _collection.delete(id));
  }
}
