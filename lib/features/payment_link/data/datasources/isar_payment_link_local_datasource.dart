import 'package:isar/isar.dart';
import '../models/payment_link_record.dart';
import 'payment_link_local_datasource.dart';

final class IsarPaymentLinkLocalDataSource implements PaymentLinkLocalDataSource {
  const IsarPaymentLinkLocalDataSource(this._isar);

  final Isar _isar;
  IsarCollection<PaymentLinkRecord> get _c => _isar.collection<PaymentLinkRecord>();

  @override Future<PaymentLinkRecord> put(PaymentLinkRecord r) async {
    final id = await _isar.writeTxn(() => _c.put(r));
    return (await _c.get(id))!;
  }

  @override Future<PaymentLinkRecord?> getById(int id) => _c.get(id);

  @override Future<PaymentLinkRecord?> getByToken(String token) async {
    final all = await _c.where().findAll();
    for (final r in all) {
      if (r.token == token && r.deletedAt == null) return r;
    }
    return null;
  }

  @override Future<PaymentLinkRecord?> getByShortCode(String code) async {
    final all = await _c.where().findAll();
    for (final r in all) {
      if (r.shortCode == code && r.deletedAt == null) return r;
    }
    return null;
  }

  @override Future<List<PaymentLinkRecord>> getByPaymentRequest(int pid) async {
    final all = await _c.where().findAll();
    return all.where((r) => r.paymentRequestId == pid && r.deletedAt == null).toList();
  }

  @override Future<List<PaymentLinkRecord>> getAll() async => _c.where().findAll();
  @override Stream<List<PaymentLinkRecord>> watchAll() => _c.watchLazy(fireImmediately: true).asyncMap((_) => getAll());
  @override Future<void> delete(int id) => _isar.writeTxn(() => _c.delete(id));
}
