import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers/app_providers.dart';
import '../../data/datasources/isar_categories_local_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/update_category.dart';
import '../../domain/usecases/watch_categories.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return CategoryRepositoryImpl(IsarCategoriesLocalDataSource(isar));
});

final createCategoryProvider = Provider<CreateCategory>((ref) {
  return CreateCategory(ref.watch(categoryRepositoryProvider));
});

final updateCategoryProvider = Provider<UpdateCategory>((ref) {
  return UpdateCategory(ref.watch(categoryRepositoryProvider));
});

final deleteCategoryProvider = Provider<DeleteCategory>((ref) {
  return DeleteCategory(ref.watch(categoryRepositoryProvider));
});

final getCategoriesProvider = Provider<GetCategories>((ref) {
  return GetCategories(ref.watch(categoryRepositoryProvider));
});

final watchCategoriesProvider = Provider<WatchCategories>((ref) {
  return WatchCategories(ref.watch(categoryRepositoryProvider));
});

final categoriesStreamProvider = StreamProvider.autoDispose<List<Category>>((ref) {
  final watchCategories = ref.watch(watchCategoriesProvider);
  return watchCategories();
});
