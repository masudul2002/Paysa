enum CategoryType {
  income,
  expense;

  String get label => switch (this) {
        CategoryType.income => 'Income',
        CategoryType.expense => 'Expense',
      };
}

enum CategoryGroup {
  housing,
  transportation,
  food,
  utilities,
  entertainment,
  shopping,
  health,
  education,
  salary,
  freelance,
  investment,
  business,
  other;

  String get label => switch (this) {
        CategoryGroup.housing => 'Housing',
        CategoryGroup.transportation => 'Transportation',
        CategoryGroup.food => 'Food & Dining',
        CategoryGroup.utilities => 'Utilities',
        CategoryGroup.entertainment => 'Entertainment',
        CategoryGroup.shopping => 'Shopping',
        CategoryGroup.health => 'Health & Fitness',
        CategoryGroup.education => 'Education',
        CategoryGroup.salary => 'Salary',
        CategoryGroup.freelance => 'Freelance',
        CategoryGroup.investment => 'Investment',
        CategoryGroup.business => 'Business',
        CategoryGroup.other => 'Other',
      };
}

final class Category {
  const Category({
    this.id = 0,
    required this.name,
    required this.type,
    this.group = CategoryGroup.other,
    required this.icon,
    required this.color,
    this.description = '',
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final CategoryType type;
  final CategoryGroup group;
  final String icon;
  final int color;
  final String description;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category copyWith({
    int? id,
    String? name,
    CategoryType? type,
    CategoryGroup? group,
    String? icon,
    int? color,
    String? description,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      group: group ?? this.group,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
