import '../models/notification_record.dart';

abstract interface class NotificationLocalDataSource {
  Future<NotificationRecord> put(NotificationRecord r);
  Future<NotificationRecord?> getById(int id);
  Future<List<NotificationRecord>> getAll();
  Stream<List<NotificationRecord>> watchAll();
  Future<void> delete(int id);
}
