enum AccountType {
  cash,
  bank,
  mobileBanking,
  creditCard,
  savings,
  investment,
  other;

  String get label => switch (this) {
        AccountType.cash => 'Cash',
        AccountType.bank => 'Bank',
        AccountType.mobileBanking => 'Mobile Banking',
        AccountType.creditCard => 'Credit Card',
        AccountType.savings => 'Savings',
        AccountType.investment => 'Investment',
        AccountType.other => 'Other',
      };
}

final class Account {
  const Account({
    this.id = 0,
    required this.name,
    required this.type,
    required this.currency,
    required this.balance,
    required this.icon,
    required this.color,
    this.description = '',
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final AccountType type;
  final String currency;
  final double balance;
  final String icon;
  final int color;
  final String description;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account copyWith({
    int? id,
    String? name,
    AccountType? type,
    String? currency,
    double? balance,
    String? icon,
    int? color,
    String? description,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
