import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_exception.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/payment_request.dart';
import '../providers/payment_request_providers.dart';

class PaymentRequestFormSheet extends ConsumerStatefulWidget {
  const PaymentRequestFormSheet({super.key, this.initialRequest});
  final PaymentRequest? initialRequest;
  @override
  ConsumerState<PaymentRequestFormSheet> createState() => _PaymentRequestFormSheetState();
}

class _PaymentRequestFormSheetState extends ConsumerState<PaymentRequestFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl, _descCtrl;
  late PaymentRequestType _selectedType;
  late bool _allowPartial, _allowOver;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool get _isEditing => widget.initialRequest != null;

  @override
  void initState() {
    super.initState();
    final r = widget.initialRequest;
    _titleCtrl = TextEditingController(text: r?.title ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _selectedType = r?.requestType ?? PaymentRequestType.generalPayment;
    _allowPartial = r?.allowPartialPayment ?? false;
    _allowOver = r?.allowOverPayment ?? false;
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canEdit = !_isEditing || (widget.initialRequest?.status.isEditable ?? true);

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(key: _formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_isEditing ? 'Edit payment request' : 'New payment request', style: theme.textTheme.titleLarge),
        const SizedBox(height: 20),
        if (_isEditing) ...[
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
            child: Text('Status: ${widget.initialRequest!.status.label}', style: theme.textTheme.labelMedium)),
          const SizedBox(height: 16),
        ],
        TextFormField(controller: _titleCtrl, readOnly: !canEdit,
          decoration: const InputDecoration(labelText: 'Title *', prefixIcon: Icon(Icons.title_outlined)),
          validator: (v) { if (v == null || v.trim().isEmpty) return 'Title is required'; return null; }),
        const SizedBox(height: 16),
        DropdownButtonFormField<PaymentRequestType>(
          initialValue: _selectedType,
          decoration: const InputDecoration(labelText: 'Type', prefixIcon: Icon(Icons.category_outlined)),
          items: PaymentRequestType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
          onChanged: canEdit ? (v) { if (v != null) setState(() => _selectedType = v); } : null,
        ),
        const SizedBox(height: 16),
        if (canEdit) ...[
          TextFormField(controller: _descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true)),
          const SizedBox(height: 16),
          CheckboxListTile(title: const Text('Allow partial payment'), value: _allowPartial, onChanged: (v) => setState(() => _allowPartial = v ?? false), dense: true, contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.trailing),
          CheckboxListTile(title: const Text('Allow overpayment'), value: _allowOver, onChanged: (v) => setState(() => _allowOver = v ?? false), dense: true, contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.trailing),
        ],
        if (_errorMessage != null) ...[const SizedBox(height: 12), AppErrorWidget(title: 'Could not save', details: _errorMessage)],
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: SecondaryButton(label: 'Cancel', onPressed: _isSubmitting ? () {} : () => Navigator.of(context).pop())),
          const SizedBox(width: 12),
          Expanded(child: PrimaryButton(label: _isSubmitting ? 'Saving...' : 'Save', onPressed: canEdit ? (_isSubmitting ? () {} : _submit) : () {})),
        ]),
      ]))),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final now = DateTime.now();

    try {
      final r = PaymentRequest(
        id: widget.initialRequest?.id ?? 0,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        requestType: _selectedType,
        amountMinor: widget.initialRequest?.amountMinor ?? 0,
        allowPartialPayment: _allowPartial,
        allowOverPayment: _allowOver,
        createdAt: widget.initialRequest?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditing) {
        await ref.read(paymentRequestRepositoryProvider).update(r);
      } else {
        await ref.read(paymentRequestRepositoryProvider).create(r);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request saved')));
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally { if (mounted) setState(() => _isSubmitting = false); }
  }
}
