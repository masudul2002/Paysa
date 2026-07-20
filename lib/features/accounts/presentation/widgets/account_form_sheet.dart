import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_exception.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_defaults.dart';
import '../providers/accounts_providers.dart';
import 'account_visuals.dart';

class AccountFormSheet extends ConsumerStatefulWidget {
  const AccountFormSheet({super.key, this.initialAccount});

  final Account? initialAccount;

  @override
  ConsumerState<AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends ConsumerState<AccountFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _descriptionController;
  late AccountType _selectedType;
  late bool _isArchived;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final account = widget.initialAccount;
    _nameController = TextEditingController(text: account?.name ?? '');
    _balanceController = TextEditingController(
      text: account?.balance.toStringAsFixed(2) ?? '0.00',
    );
    _currencyController = TextEditingController(
      text: account?.currency ?? AccountDefaults.defaultCurrency,
    );
    _descriptionController = TextEditingController(
      text: account?.description ?? '',
    );
    _selectedType = account?.type ?? AccountType.bank;
    _isArchived = account?.isArchived ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _currencyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.initialAccount;
    final isEditing = account != null;

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
                isEditing ? 'Edit account' : 'Add account',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AccountType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: AccountType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Balance'),
                validator: (value) {
                  final parsed = double.tryParse((value ?? '').trim());
                  if (parsed == null) {
                    return 'Enter a valid balance';
                  }
                  if (parsed < 0) {
                    return 'Balance must be zero or greater';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _currencyController,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Currency'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Currency is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          accountColorFromValue(AccountDefaults.colorFor(_selectedType))
                              .withValues(alpha: 0.14),
                      child: Icon(
                        accountIconFromKey(AccountDefaults.iconFor(_selectedType)),
                        color: accountColorFromValue(
                          AccountDefaults.colorFor(_selectedType),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedType.label,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isArchived) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Switch(
                      value: _isArchived,
                      onChanged: (value) => setState(() => _isArchived = value),
                    ),
                    const Text('Archived'),
                  ],
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                AppErrorWidget(title: 'Unable to save account', details: _errorMessage),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancel',
                      onPressed: _isSubmitting ? () {} : () => Navigator.of(context).pop(),
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final name = _nameController.text.trim();
    final currency = _currencyController.text.trim().toUpperCase();
    final balance = double.tryParse(_balanceController.text.trim()) ?? -1;
    final description = _descriptionController.text.trim();
    final now = DateTime.now();
    final existing = widget.initialAccount;

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      final account = Account(
        id: existing?.id ?? 0,
        name: name,
        type: _selectedType,
        currency: currency,
        balance: balance,
        icon: AccountDefaults.iconFor(_selectedType),
        color: AccountDefaults.colorFor(_selectedType),
        description: description,
        isArchived: existing?.isArchived ?? false,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      if (existing == null) {
        await ref.read(createAccountProvider).call(account);
      } else {
        await ref.read(updateAccountProvider).call(account);
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } on AppException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
