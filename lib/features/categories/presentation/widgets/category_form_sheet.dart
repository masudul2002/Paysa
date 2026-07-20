import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_exception.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_defaults.dart';
import '../providers/categories_providers.dart';
import 'category_visuals.dart';

class CategoryFormSheet extends ConsumerStatefulWidget {
  const CategoryFormSheet({super.key, this.initialCategory});

  final Category? initialCategory;

  @override
  ConsumerState<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<CategoryFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late CategoryType _selectedType;
  late CategoryGroup _selectedGroup;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final category = widget.initialCategory;
    _nameController = TextEditingController(text: category?.name ?? '');
    _descriptionController = TextEditingController(
      text: category?.description ?? '',
    );
    _selectedType = category?.type ?? CategoryType.expense;
    _selectedGroup = category?.group ?? CategoryGroup.other;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.initialCategory;
    final isEditing = category != null;

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
                isEditing ? 'Edit category' : 'Add category',
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
              DropdownButtonFormField<CategoryType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: CategoryType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CategoryGroup>(
                initialValue: _selectedGroup,
                decoration: const InputDecoration(labelText: 'Group'),
                items: CategoryGroup.values
                    .map(
                      (group) => DropdownMenuItem(
                        value: group,
                        child: Text(group.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedGroup = value;
                  });
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
                          categoryColorFromValue(
                            CategoryDefaults.colorForGroup(_selectedGroup),
                          ).withValues(alpha: 0.14),
                      child: Icon(
                        categoryIconFromKey(
                          CategoryDefaults.iconForGroup(_selectedGroup),
                        ),
                        color: categoryColorFromValue(
                          CategoryDefaults.colorForGroup(_selectedGroup),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedGroup.label,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            _selectedType.label,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                AppErrorWidget(title: 'Unable to save category', details: _errorMessage),
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
    final description = _descriptionController.text.trim();
    final now = DateTime.now();
    final existing = widget.initialCategory;

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      final category = Category(
        id: existing?.id ?? 0,
        name: name,
        type: _selectedType,
        group: _selectedGroup,
        icon: CategoryDefaults.iconForGroup(_selectedGroup),
        color: CategoryDefaults.colorForGroup(_selectedGroup),
        description: description,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      if (existing == null) {
        await ref.read(createCategoryProvider).call(category);
      } else {
        await ref.read(updateCategoryProvider).call(category);
      }

      if (!mounted) return;
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
