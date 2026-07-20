import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_exception.dart';
import '../../../../shared/shared.dart';
import '../../../accounts/presentation/providers/accounts_providers.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/widgets/category_selector.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transactions_providers.dart';

class TransactionFormSheet extends ConsumerStatefulWidget {
  const TransactionFormSheet({
    super.key,
    this.initialTransaction,
    this.preselectedAccountId,
  });

  final Transaction? initialTransaction;
  final int? preselectedAccountId;

  @override
  ConsumerState<TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _currencyController;
  late TransactionType _selectedType;
  late int? _selectedAccountId;
  int? _selectedCategoryId;
  late DateTime _selectedDate;
  bool _isPending = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final tx = widget.initialTransaction;
    _amountController = TextEditingController(
      text: tx?.amount.toStringAsFixed(2) ?? '',
    );
    _descriptionController = TextEditingController(text: tx?.description ?? '');
    _currencyController = TextEditingController(
      text: tx?.currency ?? 'USD',
    );
    _selectedType = tx?.type ?? TransactionType.expense;
    _selectedAccountId = tx?.accountId ?? widget.preselectedAccountId;
    _selectedCategoryId = tx?.categoryId;
    _selectedDate = tx?.date ?? DateTime.now();
    _isPending = tx?.isPending ?? false;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.initialTransaction;
    final isEditing = tx != null;
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
              Text(
                isEditing ? 'Edit transaction' : 'Add transaction',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // Type toggle
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_circle_down),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_circle_up),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (values) {
                  setState(() => _selectedType = values.first);
                },
              ),
              const SizedBox(height: 12),
              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (value) {
                  final parsed = double.tryParse((value ?? '').trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid amount greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Account
              accountsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Failed to load accounts'),
                data: (accounts) {
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedAccountId,
                    decoration: const InputDecoration(labelText: 'Account'),
                    items: accounts
                        .where((a) => !a.isArchived)
                        .map((account) => DropdownMenuItem<int>(
                              value: account.id,
                              child: Text(account.name),
                            ))
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedAccountId = value);
                    },
                    validator: (value) {
                      if (value == null) return 'Select an account';
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              // Category
              CategorySelector(
                selectedCategoryId: _selectedCategoryId,
                onSelected: (category) {
                  setState(() => _selectedCategoryId = category?.id);
                },
                filterType: _selectedType == TransactionType.income
                    ? CategoryType.income
                    : CategoryType.expense,
              ),
              const SizedBox(height: 12),
              // Description
              TextFormField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              // Date
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/'
                    '${_selectedDate.month.toString().padLeft(2, '0')}/'
                    '${_selectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Currency
              TextFormField(
                controller: _currencyController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Currency'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Currency is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              // Pending toggle
              CheckboxListTile(
                title: const Text('Pending'),
                subtitle: const Text('Mark as not yet settled'),
                value: _isPending,
                onChanged: (value) =>
                    setState(() => _isPending = value ?? false),
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: EdgeInsets.zero,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                AppErrorWidget(
                  title: 'Unable to save transaction',
                  details: _errorMessage,
                ),
              ],
              const SizedBox(height: 16),
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
                      label: _isSubmitting ? 'Saving...' : 'Save',
                      onPressed: _isSubmitting ? () {} : _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedAccountId == null) {
      setState(() => _errorMessage = 'Please select an account.');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? -1;
    final description = _descriptionController.text.trim();
    final currency = _currencyController.text.trim().toUpperCase();
    final now = DateTime.now();
    final existing = widget.initialTransaction;

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      final transaction = Transaction(
        id: existing?.id ?? 0,
        accountId: _selectedAccountId!,
        categoryId: _selectedCategoryId,
        type: _selectedType,
        amount: amount,
        currency: currency,
        description: description,
        date: _selectedDate,
        isPending: _isPending,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      if (existing == null) {
        await ref.read(createTransactionProvider).call(transaction);
      } else {
        await ref.read(updateTransactionProvider).call(transaction);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } on AppException catch (error) {
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
