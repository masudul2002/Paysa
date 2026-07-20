import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../providers/categories_providers.dart';
import 'category_visuals.dart';

class CategorySelector extends ConsumerWidget {
  const CategorySelector({
    super.key,
    this.selectedCategoryId,
    this.onSelected,
    this.filterType,
  });

  final int? selectedCategoryId;
  final ValueChanged<Category?>? onSelected;
  final CategoryType? filterType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return categoriesAsync.when(
      loading: () => DropdownButtonFormField<int>(
        items: [],
        onChanged: null,
        decoration: InputDecoration(labelText: 'Category'),
      ),
      error: (_, __) => const Text('Failed to load categories'),
      data: (categories) {
        final filtered = filterType != null
            ? categories.where((c) => c.type == filterType).toList(growable: false)
            : categories;

        return DropdownButtonFormField<int>(
          value: selectedCategoryId != null && filtered.any((c) => c.id == selectedCategoryId)
              ? selectedCategoryId
              : null,
          decoration: const InputDecoration(labelText: 'Category'),
          items: filtered.map((category) {
            return DropdownMenuItem<int>(
              value: category.id,
              child: Row(
                children: [
                  Icon(
                    categoryIconFromKey(category.icon),
                    size: 18,
                    color: categoryColorFromValue(category.color),
                  ),
                  const SizedBox(width: 8),
                  Text(category.name),
                ],
              ),
            );
          }).toList(growable: false),
          onChanged: (value) {
            if (value == null) return;
            final category = filtered.firstWhere((c) => c.id == value);
            onSelected?.call(category);
          },
        );
      },
    );
  }
}
