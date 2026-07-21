import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

// ---------------------------------------------------------------------------
// CurrencyField — numeric input with currency prefix
// ---------------------------------------------------------------------------

class CurrencyField extends StatelessWidget {
  const CurrencyField({
    super.key,
    required this.controller,
    this.label,
    this.currencyCode = 'USD',
    this.autofocus = false,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? label;
  final String currencyCode;
  final bool autofocus;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  @override Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label ?? 'Amount',
        prefixText: '$currencyCode ',
        prefixIcon: const Icon(Icons.attach_money_outlined),
      ),
      validator: validator ?? (v) {
        if (v == null || v.trim().isEmpty) return 'Amount is required';
        final parsed = double.tryParse(v.trim());
        if (parsed == null || parsed <= 0) return 'Enter a valid amount greater than zero';
        return null;
      },
      onChanged: onChanged,
    );
  }
}

// ---------------------------------------------------------------------------
// SearchField — search input with optional clear
// ---------------------------------------------------------------------------

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.autofocus = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final bool autofocus;
  final void Function(String)? onChanged;

  @override Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        border: InputBorder.none,
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }
}

// ---------------------------------------------------------------------------
// DatePickerField — read-only field that opens a date picker
// ---------------------------------------------------------------------------

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.controller,
    this.label,
    this.firstDate,
    this.lastDate,
  });

  final TextEditingController controller;
  final String? label;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label ?? 'Date',
        prefixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      readOnly: true,
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: firstDate ?? now.subtract(const Duration(days: 365)),
          lastDate: lastDate ?? now.add(const Duration(days: 365)),
        );
        if (picked != null) {
          controller.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        }
      },
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Date is required';
        return null;
      },
    );
  }
}

// ---------------------------------------------------------------------------
// AmountBadge — displays formatted amount with color
// ---------------------------------------------------------------------------

class AmountBadge extends StatelessWidget {
  const AmountBadge({
    super.key,
    required this.amountMinor,
    this.currencyCode = 'USD',
    this.isPositive,
    this.style,
  });

  final int amountMinor;
  final String currencyCode;
  final bool? isPositive;
  final TextStyle? style;

  @override Widget build(BuildContext context) {
    final positive = isPositive ?? amountMinor >= 0;
    final theme = Theme.of(context);
    return Text(
      '$currencyCode ${(amountMinor.abs() / 100).toStringAsFixed(2)}',
      style: (style ?? theme.textTheme.titleSmall)?.copyWith(
        fontWeight: FontWeight.w600,
        color: positive ? DesignTokens.income : DesignTokens.expense,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ConfirmationDialog
// ---------------------------------------------------------------------------

class ConfirmationDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(cancelLabel)),
          FilledButton(
            style: isDestructive ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error) : null,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BottomSheetContainer — wraps content with consistent padding
// ---------------------------------------------------------------------------

class BottomSheetContainer extends StatelessWidget {
  const BottomSheetContainer({super.key, required this.child});

  final Widget child;

  @override Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: DesignTokens.space16,
        right: DesignTokens.space16,
        top: DesignTokens.space16,
        bottom: DesignTokens.space16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: child,
    );
  }
}
