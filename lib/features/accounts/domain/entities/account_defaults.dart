import 'account.dart';

final class AccountDefaults {
  const AccountDefaults._();

  static const defaultCurrency = 'USD';

  static String iconFor(AccountType type) => switch (type) {
        AccountType.cash => 'cash',
        AccountType.bank => 'bank',
        AccountType.mobileBanking => 'mobile_banking',
        AccountType.creditCard => 'credit_card',
        AccountType.savings => 'savings',
        AccountType.investment => 'investment',
        AccountType.other => 'other',
      };

  static int colorFor(AccountType type) => switch (type) {
        AccountType.cash => 0xFF388E3C,
        AccountType.bank => 0xFF0F766E,
        AccountType.mobileBanking => 0xFF7C3AED,
        AccountType.creditCard => 0xFFB45309,
        AccountType.savings => 0xFF2563EB,
        AccountType.investment => 0xFFBE185D,
        AccountType.other => 0xFF475569,
      };
}
