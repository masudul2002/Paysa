import 'package:isar/isar.dart';
import '../models/payment_request_record.dart';
import 'payment_request_local_datasource.dart';

final class IsarPaymentRequestLocalDataSource implements PaymentRequestLocalDataSource {
  const IsarPaymentRequestLocalDataSource(this._isar);

  final Isar _isar;
  IsarCollection<PaymentRequestRecord> get _c => _isar.collection<PaymentRequestRecord>();

  @override Future<PaymentRequestRecord> put(PaymentRequestRecord record) async {
    final id = await _isar.writeTxn(() => _c.put(record));
    return (await _c.get(id))!;
  }

  @override Future<PaymentRequestRecord?> getById(int id) => _c.get(id);

  @override Future<PaymentRequestRecord?> getByRequestNumber(String requestNumber) async {
    final all = await _c.where().findAll();
    for (final r in all) {
      if (r.requestNumber.toLowerCase() == requestNumber.trim().toLowerCase() && r.deletedAt == null) return r;
    }
    return null;
  }

  @override Future<List<PaymentRequestRecord>> getAll() async => _c.where().findAll();

  @override Stream<List<PaymentRequestRecord>> watchAll() => _c.watchLazy(fireImmediately: true).asyncMap((_) => getAll());

  @override Future<void> delete(int id) => _isar.writeTxn(() => _c.delete(id));
}
