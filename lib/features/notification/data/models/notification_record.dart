import 'package:isar/isar.dart';
import '../../domain/entities/notification_item.dart';

part 'notification_record.g.dart';

@Collection(inheritance: false)
class NotificationRecord {
  NotificationRecord();
  Id id = Isar.autoIncrement;
  late int type; late String title; late String body;
  String? entityType; int? entityId; late int status;
  late int priority; DateTime? snoozedUntil; late DateTime createdAt;
}

extension NotificationRecordMapper on NotificationRecord {
  NotificationItem toEntity() => NotificationItem(
    id: id, type: NotificationType.values[type],
    title: title, body: body,
    entityType: entityType, entityId: entityId,
    status: NotificationStatus.values[status],
    priority: priority, snoozedUntil: snoozedUntil,
    createdAt: createdAt,
  );
}

extension NotificationEntityMapper on NotificationItem {
  NotificationRecord toRecord() {
    final r = NotificationRecord()
      ..id = id ..type = type.index ..title = title ..body = body
      ..entityType = entityType ..entityId = entityId ..status = status.index
      ..priority = priority ..snoozedUntil = snoozedUntil ..createdAt = createdAt;
    return r;
  }
}
