import 'package:flutter/material.dart';

/// Custom color extension for the Paysa app.
///
/// Access via `Theme.of(context).extension<PaysaColors>()`.
final class PaysaColors extends ThemeExtension<PaysaColors> {
  const PaysaColors({
    required this.income,
    required this.expense,
    required this.pending,
    required this.receivable,
    required this.payable,
  });

  final Color income;
  final Color expense;
  final Color pending;
  final Color receivable;
  final Color payable;

  @override
  PaysaColors copyWith({
    Color? income,
    Color? expense,
    Color? pending,
    Color? receivable,
    Color? payable,
  }) => PaysaColors(
    income: income ?? this.income,
    expense: expense ?? this.expense,
    pending: pending ?? this.pending,
    receivable: receivable ?? this.receivable,
    payable: payable ?? this.payable,
  );

  @override
  PaysaColors lerp(ThemeExtension<PaysaColors>? other, double t) {
    if (other is! PaysaColors) return this;
    return PaysaColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      pending: Color.lerp(pending, other.pending, t)!,
      receivable: Color.lerp(receivable, other.receivable, t)!,
      payable: Color.lerp(payable, other.payable, t)!,
    );
  }
}
