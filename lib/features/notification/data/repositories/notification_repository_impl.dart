import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';
import '../models/notification_record.dart';

final class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._ds);
  final NotificationLocalDataSource _ds;

  @override Future<NotificationItem> create(NotificationItem item) async {
    return (await _ds.put(item.toRecord())).toEntity();
  }

  @override Future<NotificationItem?> getById(int id) async => (await _ds.getById(id))?.toEntity();

  @override Future<List<NotificationItem>> getAll({NotificationType? typeFilter, NotificationStatus? statusFilter}) async {
    var all = await _ds.getAll();
    if (typeFilter != null) all = all.where((r) => r.type == typeFilter.index).toList();
    if (statusFilter != null) all = all.where((r) => r.status == statusFilter.index).toList();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all.map((r) => r.toEntity()).toList();
  }

  @override Future<List<NotificationItem>> getToday() async {
    final all = await _ds.getAll();
    final today = DateTime.now();
    return all.where((r) =>
      r.createdAt.year == today.year &&
      r.createdAt.month == today.month &&
      r.createdAt.day == today.day &&
      r.status != NotificationStatus.dismissed.index
    ).map((r) => r.toEntity()).toList();
  }

  @override Stream<List<NotificationItem>> watchAll() => _ds.watchAll().map((l) => l.map((r) => r.toEntity()).toList());

  @override Future<void> markRead(int id) async {
    final r = await _ds.getById(id);
    if (r == null) return;
    r.status = NotificationStatus.read.index; await _ds.put(r);
  }

  @override Future<void> dismiss(int id) async {
    final r = await _ds.getById(id);
    if (r == null) return;
    r.status = NotificationStatus.dismissed.index; await _ds.put(r);
  }

  @override Future<void> snooze(int id, DateTime until) async {
    final r = await _ds.getById(id);
    if (r == null) return;
    r.status = NotificationStatus.snoozed.index;
    r.snoozedUntil = until; await _ds.put(r);
  }

  @override Future<void> delete(int id) async => _ds.delete(id);

  @override Future<NotificationItem> generateFromRule(ReminderRule rule) async {
    return create(NotificationItem(
      type: rule.type,
      title: rule.type.label,
      body: 'Reminder for ${rule.entityType}#${rule.entityId}',
      entityType: rule.entityType,
      entityId: rule.entityId,
      status: NotificationStatus.unread,
      createdAt: DateTime.now(),
    ));
  }
}
