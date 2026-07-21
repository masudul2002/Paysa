/// Firestore collection names used by Paysa.
///
/// Centralized to prevent typos and enable easy renaming.
final class FirestoreCollections {
  const FirestoreCollections._();

  static const accounts = 'accounts';
  static const transactions = 'transactions';
  static const categories = 'categories';
  static const budgets = 'budgets';
  static const goals = 'goals';
  static const settings = 'settings';
  static const people = 'people';
  static const ledgers = 'ledgers';
  static const ledgerEntries = 'ledgerEntries';
  static const paymentRequests = 'paymentRequests';
  static const receipts = 'receipts';

  /// All collection names for batch operations.
  static List<String> get all => [
    accounts, transactions, categories, budgets,
    goals, settings, people, ledgers, ledgerEntries,
    paymentRequests, receipts,
  ];
}
