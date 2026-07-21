import 'package:isar/isar.dart';
import '../models/notification_record.dart';
import 'notification_local_datasource.dart';

final class IsarNotificationLocalDataSource implements NotificationLocalDataSource {
  const IsarNotificationLocalDataSource(this._isar);
  final Isar _isar;
  IsarCollection<NotificationRecord> get _c => _isar.collection<NotificationRecord>();
  @override Future<NotificationRecord> put(NotificationRecord r) async { final id = await _isar.writeTxn(() => _c.put(r)); return (await _c.get(id))!; }
  @override Future<NotificationRecord?> getById(int id) => _c.get(id);
  @override Future<List<NotificationRecord>> getAll() async => _c.where().findAll();
  @override Stream<List<NotificationRecord>> watchAll() => _c.watchLazy(fireImmediately: true).asyncMap((_) => getAll());
  @override Future<void> delete(int id) => _isar.writeTxn(() => _c.delete(id));
}
