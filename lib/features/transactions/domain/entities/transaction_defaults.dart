import 'transaction.dart';

final class TransactionDefaults {
  const TransactionDefaults._();

  static List<String> defaultTagsFor(TransactionType type) => switch (type) {
        TransactionType.income => ['salary', 'freelance', 'investment', 'gift', 'other'],
        TransactionType.expense => [
            'food',
            'transport',
            'shopping',
            'bills',
            'entertainment',
            'health',
            'education',
            'other',
          ],
      };
}
