import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_exception.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_method_type.dart';
import '../providers/payment_method_providers.dart';

class PaymentMethodFormSheet extends ConsumerStatefulWidget {
  const PaymentMethodFormSheet({super.key, this.initialMethod});
  final PaymentMethod? initialMethod;
  @override
  ConsumerState<PaymentMethodFormSheet> createState() => _PaymentMethodFormSheetState();
}

class _PaymentMethodFormSheetState extends ConsumerState<PaymentMethodFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late PaymentMethodType _selectedType;
  late bool _isEnabled;
  late bool _isFavorite;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.initialMethod != null;
  bool get _isBuiltIn => widget.initialMethod?.isBuiltIn == true;

  @override
  void initState() {
    super.initState();
    final m = widget.initialMethod;
    _nameCtrl = TextEditingController(text: m?.name ?? '');
    _descCtrl = TextEditingController(text: m?.description ?? '');
    _selectedType = m?.type ?? PaymentMethodType.other;
    _isEnabled = m?.isEnabled ?? true;
    _isFavorite = m?.isFavorite ?? false;
  }

  @override
  void dispose() { _nameCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(key: _formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_isEditing ? 'Edit payment method' : 'Add payment method', style: theme.textTheme.titleLarge),
        const SizedBox(height: 20),
        TextFormField(controller: _nameCtrl, readOnly: _isBuiltIn,
          decoration: InputDecoration(labelText: 'Name *', prefixIcon: const Icon(Icons.payment_outlined)),
          validator: (v) { if (v == null || v.trim().isEmpty) return 'Name is required'; if (v.trim().length > 50) return 'Max 50 characters'; return null; }),
        const SizedBox(height: 16),
        DropdownButtonFormField<PaymentMethodType>(
          initialValue: _selectedType,
          decoration: const InputDecoration(labelText: 'Type', prefixIcon: Icon(Icons.category_outlined)),
          items: PaymentMethodType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
          onChanged: _isBuiltIn ? null : (v) { if (v != null) setState(() => _selectedType = v); },
        ),
        if (!_isBuiltIn) ...[
          const SizedBox(height: 16),
          TextFormField(controller: _descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true)),
        ],
        if (!_isBuiltIn) ...[
          const SizedBox(height: 12),
          CheckboxListTile(title: const Text('Enabled'), value: _isEnabled, onChanged: (v) => setState(() => _isEnabled = v ?? false), contentPadding: EdgeInsets.zero, dense: true, controlAffinity: ListTileControlAffinity.trailing),
        ],
        CheckboxListTile(title: const Text('Mark as favorite'), value: _isFavorite, onChanged: (v) => setState(() => _isFavorite = v ?? false), contentPadding: EdgeInsets.zero, dense: true, controlAffinity: ListTileControlAffinity.trailing),
        if (_errorMessage != null) ...[const SizedBox(height: 12), AppErrorWidget(title: 'Could not save', details: _errorMessage)],
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: SecondaryButton(label: 'Cancel', onPressed: _isSubmitting ? () {} : () => Navigator.of(context).pop())),
          const SizedBox(width: 12),
          Expanded(child: PrimaryButton(label: _isSubmitting ? 'Saving...' : 'Save', onPressed: _isSubmitting ? () {} : _submit)),
        ]),
      ]))),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _errorMessage = null; _isSubmitting = true; });

    try {
      final m = PaymentMethod(
        id: widget.initialMethod?.id ?? 0,
        name: _nameCtrl.text.trim(),
        type: _selectedType,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        isBuiltIn: _isBuiltIn,
        isEnabled: _isEditing ? _isEnabled : true,
        isFavorite: _isFavorite,
        createdAt: widget.initialMethod?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await ref.read(paymentMethodRepositoryProvider).update(m);
      } else {
        await ref.read(paymentMethodRepositoryProvider).create(m);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${m.name} saved')));
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally { if (mounted) setState(() => _isSubmitting = false); }
  }
}
