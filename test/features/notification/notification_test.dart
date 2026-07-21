import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/notification/data/datasources/notification_local_datasource.dart';
import 'package:paysa/features/notification/data/models/notification_record.dart';
import 'package:paysa/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:paysa/features/notification/domain/entities/notification_item.dart';
import 'package:paysa/features/notification/domain/repositories/notification_repository.dart';

final class _MemDS implements NotificationLocalDataSource {
  final _r = <int, NotificationRecord>{}; int _n = 1;
  @override Future<NotificationRecord> put(NotificationRecord r) async { if (r.id == 0) r.id = _n++; _r[r.id] = r; return r; }
  @override Future<NotificationRecord?> getById(int id) async => _r[id];
  @override Future<List<NotificationRecord>> getAll() async => _r.values.toList();
  @override Stream<List<NotificationRecord>> watchAll() async* { yield _r.values.toList(); }
  @override Future<void> delete(int id) async { _r.remove(id); }
}

final _now = DateTime.now();

void main() {
  late NotificationRepository repo;
  setUp(() { repo = NotificationRepositoryImpl(_MemDS()); });

  group('create', () {
    test('creates a notification', () async {
      final n = await repo.create(NotificationItem(type: NotificationType.custom, title: 'Test', body: 'Body', createdAt: _now));
      expect(n.id, greaterThan(0));
      expect(n.type, NotificationType.custom);
    });
  });

  group('markRead / dismiss / snooze', () {
    test('mark read updates status', () async {
      final n = await repo.create(NotificationItem(type: NotificationType.custom, title: 'T', body: 'B', createdAt: _now));
      await repo.markRead(n.id);
      expect((await repo.getById(n.id))?.status, NotificationStatus.read);
    });

    test('dismiss marks dismissed', () async {
      final n = await repo.create(NotificationItem(type: NotificationType.custom, title: 'T', body: 'B', createdAt: _now));
      await repo.dismiss(n.id);
      expect((await repo.getById(n.id))?.status, NotificationStatus.dismissed);
    });

    test('snooze sets snoozedUntil', () async {
      final n = await repo.create(NotificationItem(type: NotificationType.custom, title: 'T', body: 'B', createdAt: _now));
      final until = _now.add(const Duration(hours: 2));
      await repo.snooze(n.id, until);
      final updated = await repo.getById(n.id);
      expect(updated?.status, NotificationStatus.snoozed);
      expect(updated?.snoozedUntil?.hour, until.hour);
    });
  });

  group('getToday', () {
    test('returns today notifications', () async {
      await repo.create(NotificationItem(type: NotificationType.custom, title: 'Today', body: 'B', createdAt: _now));
      await repo.create(NotificationItem(type: NotificationType.custom, title: 'Old', body: 'B', createdAt: _now.subtract(const Duration(days: 5))));
      final today = await repo.getToday();
      expect(today.length, 1);
    });
  });

  group('generateFromRule', () {
    test('creates notification from rule', () async {
      final rule = ReminderRule(
        type: NotificationType.recurringDue,
        entityType: 'recurring', entityId: 1,
        leadDays: 1,
      );
      final n = await repo.generateFromRule(rule);
      expect(n.type, NotificationType.recurringDue);
      expect(n.entityId, 1);
    });
  });

  group('NotificationType', () {
    test('all 7 types have labels', () { expect(NotificationType.values.length, 7); });
  });

  group('NotificationStatus', () {
    test('all 4 statuses exist', () { expect(NotificationStatus.values.length, 4); });
  });
}
