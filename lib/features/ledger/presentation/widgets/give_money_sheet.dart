import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_exception.dart';
import '../../../../shared/shared.dart';
import '../../../accounts/presentation/providers/accounts_providers.dart';
import '../../domain/entities/ledger.dart';
import '../providers/ledger_providers.dart';

/// Bottom sheet for recording a Give Money entry.
///
/// Give Money represents money the user gives to another person
/// — lending, gifting, paying a supplier, etc.
/// It increases the person's outstanding balance and debits the user's account.
class GiveMoneySheet extends ConsumerStatefulWidget {
  const GiveMoneySheet({
    super.key,
    required this.personId,
    required this.personName,
    required this.ledgerId,
  });

  final int personId;
  final String personName;
  final int ledgerId;

  @override
  ConsumerState<GiveMoneySheet> createState() => _GiveMoneySheetState();
}

class _GiveMoneySheetState extends ConsumerState<GiveMoneySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _notesCtrl;
  int? _selectedPaymentMethodId;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Payment methods: hardcoded IDs for system presets
  // 1=Cash, 2=Bank Transfer, 3=Credit Card, 4=Debit Card,
  // 5=bKash, 6=Nagad, 7=Rocket, 8=Upay, 9=Cheque, 10=Mobile Banking

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
    _dateCtrl = TextEditingController(
      text: _formatDate(DateTime.now()),
    );
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

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
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
              Text('Give Money', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Record money given to ${widget.personName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // Amount
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
                              Icon(
                                pm['icon'] as IconData,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
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
                  final active =
                      accounts.where((a) => !a.isArchived).toList();
                  if (active.isEmpty) return const SizedBox.shrink();

                  return Column(
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: active.first.id,
                        decoration: const InputDecoration(
                          labelText: 'From account',
                          prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                        ),
                        items: active
                            .map((a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text(
                                      '${a.name} (${a.currency} ${a.balance.toStringAsFixed(2)})'),
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

              // Attachment placeholder
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Attachment support coming soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.attach_file_outlined, size: 18),
                label: const Text('Add attachment'),
              ),
              const SizedBox(height: 12),

              // Error
              if (_errorMessage != null) ...[
                AppErrorWidget(
                  title: 'Could not save entry',
                  details: _errorMessage,
                ),
                const SizedBox(height: 12),
              ],

              // Actions
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancel',
                      onPressed:
                          _isSubmitting ? () {} : () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: _isSubmitting ? 'Saving...' : 'Give Money',
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
  // Submit
  // --------------------------------------------------------------------------

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amountParsed = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final amount = (amountParsed * 100).round();
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
        entryType: LedgerEntryType.give,
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
        SnackBar(content: Text('USD ${(amount / 100).toStringAsFixed(2)} given to ${widget.personName}')),
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
    if (picked != null) {
      _dateCtrl.text = _formatDate(picked);
    }
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
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
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
