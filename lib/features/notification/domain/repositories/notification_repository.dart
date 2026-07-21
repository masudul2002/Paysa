import '../entities/notification_item.dart';

abstract interface class NotificationRepository {
  Future<NotificationItem> create(NotificationItem item);
  Future<NotificationItem?> getById(int id);
  Future<List<NotificationItem>> getAll({NotificationType? typeFilter, NotificationStatus? statusFilter});
  Future<List<NotificationItem>> getToday();
  Stream<List<NotificationItem>> watchAll();
  Future<void> markRead(int id);
  Future<void> dismiss(int id);
  Future<void> snooze(int id, DateTime until);
  Future<void> delete(int id);
  Future<NotificationItem> generateFromRule(ReminderRule rule);
}
