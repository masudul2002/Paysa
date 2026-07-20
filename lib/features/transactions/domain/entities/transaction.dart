enum TransactionType {
  income,
  expense;

  String get label => switch (this) {
        TransactionType.income => 'Income',
        TransactionType.expense => 'Expense',
      };

  bool get isIncome => this == TransactionType.income;
  bool get isExpense => this == TransactionType.expense;
}

final class Transaction {
  const Transaction({
    this.id = 0,
    required this.accountId,
    this.categoryId,
    required this.type,
    required this.amount,
    required this.currency,
    this.description = '',
    required this.date,
    this.isPending = false,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int accountId;
  final int? categoryId;
  final TransactionType type;
  final double amount;
  final String currency;
  final String description;
  final DateTime date;
  final bool isPending;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get signedAmount => type.isExpense ? -amount : amount;

  Transaction copyWith({
    int? id,
    int? accountId,
    int? categoryId,
    TransactionType? type,
    double? amount,
    String? currency,
    String? description,
    DateTime? date,
    bool? isPending,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      date: date ?? this.date,
      isPending: isPending ?? this.isPending,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
