import 'package:flutter/material.dart';

import '../../../accounts/domain/entities/account.dart';
import '../../domain/entities/transaction.dart';

Color transactionColorFromValue(int colorValue) {
  return Color(colorValue);
}

IconData transactionIconFromKey(String key) {
  return switch (key) {
    'cash' => Icons.money_outlined,
    'bank' => Icons.account_balance_outlined,
    'mobile_banking' => Icons.phone_android_outlined,
    'credit_card' => Icons.credit_card_outlined,
    'savings' => Icons.savings_outlined,
    'investment' => Icons.trending_up_outlined,
    'other' => Icons.account_balance_wallet_outlined,
    _ => Icons.receipt_long_outlined,
  };
}

String formatCurrency(double amount, String currency) {
  return '$currency ${amount.toStringAsFixed(2)}';
}

Color amountColorFor(Transaction transaction, {bool negativeInRed = true}) {
  if (negativeInRed && transaction.type == TransactionType.expense) {
    return Colors.red.shade700;
  }
  return Colors.green.shade700;
}

String accountNameFromId(Account? account) {
  return account?.name ?? 'Unknown account';
}
