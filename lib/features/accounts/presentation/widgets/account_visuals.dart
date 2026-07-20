import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/account_defaults.dart';

IconData accountIconFromKey(String key) => switch (key) {
      'cash' => Icons.payments_outlined,
      'bank' => Icons.account_balance_outlined,
      'mobile_banking' => Icons.smartphone_outlined,
      'credit_card' => Icons.credit_card_outlined,
      'savings' => Icons.savings_outlined,
      'investment' => Icons.trending_up_outlined,
      _ => Icons.account_balance_wallet_outlined,
    };

Color accountColorFromValue(int value) => Color(value);

IconData accountTypeIcon(AccountType type) {
  return accountIconFromKey(AccountDefaults.iconFor(type));
}

String formatAccountBalance(double balance, String currency) {
  final symbol = switch (currency.toUpperCase()) {
    'USD' => r'$',
    'EUR' => '€',
    'GBP' => '£',
    'BDT' => '৳',
    'INR' => '₹',
    _ => currency.toUpperCase(),
  };

  return NumberFormat.currency(symbol: symbol, decimalDigits: 2).format(balance);
}
