import 'package:isar/isar.dart';

import '../../domain/entities/category.dart';

part 'category_record.g.dart';

@Collection(inheritance: false)
class CategoryRecord {
  CategoryRecord();

  Id id = Isar.autoIncrement;

  @Index(unique: true, caseSensitive: false)
  late String name;

  @Enumerated(EnumType.name)
  late CategoryType type;

  @Enumerated(EnumType.name)
  late CategoryGroup group;

  late String icon;
  late int color;
  String? description;
  late bool isArchived;
  late DateTime createdAt;
  late DateTime updatedAt;
}

extension CategoryRecordMapper on CategoryRecord {
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      type: type,
      group: group,
      icon: icon,
      color: color,
      description: description ?? '',
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension CategoryEntityMapper on Category {
  CategoryRecord toRecord() {
    final record = CategoryRecord()
      ..id = id
      ..name = name.trim()
      ..type = type
      ..group = group
      ..icon = icon
      ..color = color
      ..description = description.trim().isEmpty ? null : description.trim()
      ..isArchived = isArchived
      ..createdAt = createdAt
      ..updatedAt = updatedAt;
    return record;
  }
}
