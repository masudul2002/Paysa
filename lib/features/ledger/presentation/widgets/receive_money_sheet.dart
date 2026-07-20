import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_exception.dart';
import '../../../../shared/shared.dart';
import '../../../accounts/presentation/providers/accounts_providers.dart';
import '../../domain/entities/ledger.dart';
import '../providers/ledger_providers.dart';

/// Bottom sheet for recording money received from a person.
///
/// Represents repayment, collection, cash gift, or payment from a customer.
/// Decreases the person's outstanding balance and credits the user's account.
class ReceiveMoneySheet extends ConsumerStatefulWidget {
  const ReceiveMoneySheet({
    super.key,
    required this.personId,
    required this.personName,
    required this.ledgerId,
    this.currentBalance = 0,
    this.receivableAmount = 0,
    this.payableAmount = 0,
  });

  final int personId;
  final String personName;
  final int ledgerId;
  final int currentBalance;
  final int receivableAmount;
  final int payableAmount;

  @override
  ConsumerState<ReceiveMoneySheet> createState() => _ReceiveMoneySheetState();
}

class _ReceiveMoneySheetState extends ConsumerState<ReceiveMoneySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _notesCtrl;
  int? _selectedPaymentMethodId;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _overpaymentConfirmed = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
    _dateCtrl = TextEditingController(text: _formatDate(DateTime.now()));
    _descriptionCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    _descriptionCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(filteredAccountsProvider);
    final balanceAsync = ref.watch(ledgerBalanceStreamProvider(widget.ledgerId));
    final receivable = widget.receivableAmount;
    final payable = widget.payableAmount;

    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text('Receive Money', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Record money received from ${widget.personName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Balance summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: receivable > 0
                      ? Colors.green.withValues(alpha: 0.08)
                      : Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      receivable > 0
                          ? Icons.trending_up_outlined
                          : Icons.trending_down_outlined,
                      color: receivable > 0 ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        receivable > 0
                            ? 'Receivable: USD ${(receivable / 100).toStringAsFixed(2)}'
                            : 'You owe: USD ${(payable / 100).toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: receivable > 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  hintText: '0.00',
                  prefixText: 'USD ',
                  prefixIcon: Icon(Icons.attach_money_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Amount is required';
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid amount greater than zero';
                  }
                  return null;
                },
              ),
              if (receivable > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Maximum to fully settle: USD ${(receivable / 100).toStringAsFixed(2)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Payment method
              DropdownButtonFormField<int>(
                initialValue: null,
                decoration: const InputDecoration(
                  labelText: 'Payment method',
                  prefixIcon: Icon(Icons.payment_outlined),
                ),
                items: _paymentMethods
                    .map((pm) => DropdownMenuItem(
                          value: pm['id'] as int,
                          child: Row(
                            children: [
                              Icon(pm['icon'] as IconData,
                                  size: 20, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(pm['name'] as String),
                            ],
                          ),
                        ))
                    .toList(growable: false),
                onChanged: (v) => setState(() => _selectedPaymentMethodId = v),
              ),
              const SizedBox(height: 16),

              // Account selector
              accountsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (accounts) {
                  final active = accounts.where((a) => !a.isArchived).toList();
                  if (active.isEmpty) return const SizedBox.shrink();

                  return Column(
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: active.first.id,
                        decoration: const InputDecoration(
                          labelText: 'To account',
                          prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                        ),
                        items: active
                            .map((a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text(
                                    '${a.name} (${a.currency} ${a.balance.toStringAsFixed(2)})',
                                  ),
                                ))
                            .toList(growable: false),
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),

              // Date
              TextFormField(
                controller: _dateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Date *',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                readOnly: true,
                onTap: _pickDate,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Date is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What is this for?',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (v) {
                  if (v != null && v.trim().length > 200) {
                    return 'Description must be under 200 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Additional details...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),

              // Overpayment warning
              if (_overpaymentWarning != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overpayment Warning',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _overpaymentWarning!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('I understand, proceed with overpayment'),
                  value: _overpaymentConfirmed,
                  onChanged: (v) =>
                      setState(() => _overpaymentConfirmed = v ?? false),
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                const SizedBox(height: 8),
              ],

              // Error
              if (_errorMessage != null) ...[
                AppErrorWidget(title: 'Could not save', details: _errorMessage),
                const SizedBox(height: 12),
              ],

              // Actions
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancel',
                      onPressed: _isSubmitting
                          ? () {}
                          : () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: _isSubmitting ? 'Saving...' : 'Receive',
                      onPressed: _isSubmitting ? () {} : _submit,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Overpayment warning
  // --------------------------------------------------------------------------

  String? get _overpaymentWarning {
    final parsed = double.tryParse(_amountCtrl.text.trim());
    if (parsed == null || parsed <= 0) return null;
    final entered = (parsed * 100).round();
    final receivable = widget.receivableAmount;

    if (receivable > 0 && entered > receivable) {
      final excess = entered - receivable;
      return 'Receiving USD ${(entered / 100).toStringAsFixed(2)} exceeds the '
          'outstanding receivable of USD ${(receivable / 100).toStringAsFixed(2)} '
          'by USD ${(excess / 100).toStringAsFixed(2)}. '
          'The excess will be recorded as a credit (you will owe '
          '${widget.personName}).';
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // Submit
  // --------------------------------------------------------------------------

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final parsed = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final amount = (parsed * 100).round();
    final receivable = widget.receivableAmount;

    if (receivable > 0 && amount > receivable && !_overpaymentConfirmed) {
      setState(() {
        _errorMessage =
            'Please confirm the overpayment to continue.';
      });
      return;
    }

    final description = _descriptionCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    final date = _parseDate(_dateCtrl.text.trim()) ?? DateTime.now();
    final now = DateTime.now();

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      final entry = LedgerEntry(
        ledgerId: widget.ledgerId,
        personId: widget.personId,
        entryType: LedgerEntryType.receive,
        amount: amount,
        currencyCode: 'USD',
        paymentMethodId: _selectedPaymentMethodId,
        transactionDate: date,
        description: description.isEmpty ? null : description,
        notes: notes.isEmpty ? null : notes,
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(createLedgerEntryProvider).call(entry);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'USD ${(amount / 100).toStringAsFixed(2)} received from '
            '${widget.personName}',
          ),
        ),
      );
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // --------------------------------------------------------------------------
  // Date picker
  // --------------------------------------------------------------------------

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) _dateCtrl.text = _formatDate(picked);
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime? _parseDate(String s) {
    try {
      final parts = s.split('-');
      if (parts.length != 3) return null;
      return DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } catch (_) {
      return null;
    }
  }

  static const _paymentMethods = [
    {'id': 1, 'name': 'Cash', 'icon': Icons.money_outlined},
    {'id': 2, 'name': 'Bank Transfer', 'icon': Icons.account_balance_outlined},
    {'id': 3, 'name': 'Credit Card', 'icon': Icons.credit_card_outlined},
    {'id': 4, 'name': 'Debit Card', 'icon': Icons.credit_card_outlined},
    {'id': 5, 'name': 'bKash', 'icon': Icons.phone_android_outlined},
    {'id': 6, 'name': 'Nagad', 'icon': Icons.phone_android_outlined},
    {'id': 7, 'name': 'Rocket', 'icon': Icons.phone_android_outlined},
    {'id': 8, 'name': 'Upay', 'icon': Icons.phone_android_outlined},
    {'id': 9, 'name': 'Cheque', 'icon': Icons.receipt_outlined},
    {'id': 10, 'name': 'Mobile Banking', 'icon': Icons.phone_iphone_outlined},
  ];
}
