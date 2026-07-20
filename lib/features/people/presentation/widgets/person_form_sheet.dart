import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_exception.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/person.dart';
import '../../domain/entities/person_defaults.dart';
import '../providers/people_providers.dart';
import 'person_visuals.dart';

/// Full-screen modal bottom sheet for creating or editing a person.
class PersonFormSheet extends ConsumerStatefulWidget {
  const PersonFormSheet({super.key, this.initialPerson});

  /// If non-null, the form is in edit mode and pre-fills all fields.
  final Person? initialPerson;

  @override
  ConsumerState<PersonFormSheet> createState() => _PersonFormSheetState();
}

class _PersonFormSheetState extends ConsumerState<PersonFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _balanceCtrl;
  late final TextEditingController _currencyCtrl;
  late PersonType _selectedType;
  late OpeningBalanceDirection _balanceDirection;
  bool _isFavorite = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.initialPerson != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initialPerson;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _phoneCtrl = TextEditingController(text: p?.phone ?? '');
    _emailCtrl = TextEditingController(text: p?.email ?? '');
    _addressCtrl = TextEditingController(text: p?.address ?? '');
    _notesCtrl = TextEditingController(text: p?.notes ?? '');
    _balanceCtrl = TextEditingController(
      text: p != null && p.openingBalance > 0
          ? (p.openingBalance / 100).toStringAsFixed(2)
          : '',
    );
    _currencyCtrl = TextEditingController(
      text: p?.currency ?? PersonDefaults.defaultCurrency,
    );
    _selectedType = p?.type ?? PersonType.other;
    _balanceDirection =
        p?.openingBalanceDirection ?? OpeningBalanceDirection.none;
    _isFavorite = p?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    _balanceCtrl.dispose();
    _currencyCtrl.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Build
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              // ---- Title ----
              Text(
                _isEditing ? 'Edit person' : 'Add person',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              // ---- Photo ----
              Center(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Photo picker coming soon'),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: personTypeColor(_selectedType)
                            .withValues(alpha: 0.14),
                        child: Icon(
                          personTypeIcon(_selectedType),
                          size: 40,
                          color: personTypeColor(_selectedType),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 16,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ---- Name ----
              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name *',
                  hintText: 'e.g. Rafiq Ahmed',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
                  if (v.trim().length > 100) return 'Name must be under 100 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---- Type ----
              DropdownButtonFormField<PersonType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: PersonType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Row(
                      children: [
                        Icon(personTypeIcon(t),
                            size: 20, color: personTypeColor(t)),
                        const SizedBox(width: 8),
                        Text(t.label),
                      ],
                    ),
                  );
                }).toList(growable: false),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selectedType = v);
                },
              ),
              const SizedBox(height: 16),

              // ---- Phone ----
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: '+8801712345678',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty && v.trim().length < 5) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---- Email ----
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  hintText: 'rafiq@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!ok.hasMatch(v.trim())) return 'Invalid email format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---- Address ----
              TextFormField(
                controller: _addressCtrl,
                textInputAction: TextInputAction.next,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // ---- Opening balance (create only) ----
              if (!_isEditing) ...[
                const Divider(height: 1),
                const SizedBox(height: 16),
                Text('Opening Balance',
                    style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  'Set an initial amount this person owes you (or you owe them).',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _balanceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          hintText: '0.00',
                          prefixText: '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<
                          OpeningBalanceDirection>(
                        initialValue: _balanceDirection,
                        decoration: const InputDecoration(
                          labelText: 'Direction',
                        ),
                        items: OpeningBalanceDirection.values
                            .where((d) => d != OpeningBalanceDirection.none)
                            .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d.label),
                                ))
                            .toList(growable: false),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _balanceDirection = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _currencyCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    hintText: 'USD',
                    prefixIcon: Icon(Icons.monetization_on_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Currency is required';
                    }
                    if (v.trim().length != 3) {
                      return 'Use 3-letter ISO code (e.g. USD, BDT)';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 16),

              // ---- Notes ----
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Any additional information...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),

              // ---- Favorite ----
              CheckboxListTile(
                title: const Text('Mark as favorite'),
                subtitle: const Text('Favorites appear first in lists'),
                value: _isFavorite,
                onChanged: (v) => setState(() => _isFavorite = v ?? false),
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),

              // ---- Preview card ----
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: personTypeColor(_selectedType)
                          .withValues(alpha: 0.14),
                      child: Icon(
                        personTypeIcon(_selectedType),
                        color: personTypeColor(_selectedType),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameCtrl.text.isNotEmpty
                                ? _nameCtrl.text
                                : 'Full Name',
                            style: theme.textTheme.bodyLarge,
                          ),
                          Text(
                            _selectedType.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ---- Error ----
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                AppErrorWidget(
                  title: 'Unable to save',
                  details: _errorMessage,
                ),
              ],

              const SizedBox(height: 20),

              // ---- Actions ----
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

    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    final currency = _currencyCtrl.text.trim().toUpperCase();
    final now = DateTime.now();
    final existing = widget.initialPerson;

    int? openingBalance;
    if (!_isEditing) {
      final parsed = double.tryParse(_balanceCtrl.text.trim());
      if (parsed != null && parsed > 0) {
        openingBalance = (parsed * 100).round();
      }
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      final person = Person(
        id: existing?.id ?? 0,
        name: name,
        type: _selectedType,
        phone: phone.isEmpty ? null : phone,
        email: email.isEmpty ? null : email,
        address: address.isEmpty ? null : address,
        notes: notes.isEmpty ? null : notes,
        openingBalance: openingBalance ?? existing?.openingBalance ?? 0,
        openingBalanceDirection: openingBalance != null
            ? _balanceDirection
            : (existing?.openingBalanceDirection ??
                OpeningBalanceDirection.none),
        currency: currency,
        isFavorite: _isFavorite,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditing) {
        await ref.read(updatePersonProvider).call(person);
      } else {
        await ref.read(createPersonProvider).call(person);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? '${person.name} updated'
                : '${person.name} added',
          ),
        ),
      );
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
