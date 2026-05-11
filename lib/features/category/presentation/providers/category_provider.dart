import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/providers/isar_provider.dart';
import 'package:sisasaku/features/category/data/datasources/category_local_datasource.dart';
import 'package:sisasaku/features/category/data/repositories/category_repository_impl.dart';
import 'package:sisasaku/features/category/domain/entities/category_entity.dart';
import 'package:sisasaku/features/category/domain/repositories/category_repository.dart';

/// Provider untuk CategoryLocalDatasource
final categoryLocalDatasourceProvider = FutureProvider<CategoryLocalDatasource>(
  (ref) async {
    final isar = ref.watch(isarProvider);
    return CategoryLocalDatasource(isar);
  },
);

/// Provider untuk CategoryRepository
final categoryRepositoryProvider = FutureProvider<CategoryRepository>((
  ref,
) async {
  final datasource = await ref.watch(categoryLocalDatasourceProvider.future);
  return CategoryRepositoryImpl(datasource);
});

/// Provider untuk daftar kategori (StateNotifier)
final categoriesProvider = StreamProvider<List<CategoryEntity>>((ref) async* {
  final repository = await ref.watch(categoryRepositoryProvider.future);
  yield await repository.getCategories();
});

/// Provider untuk add kategori
final addCategoryProvider =
    FutureProvider.family<CategoryEntity, CategoryEntity>((
      ref,
      category,
    ) async {
      final repository = await ref.watch(categoryRepositoryProvider.future);
      return repository.addCategory(category);
    });

/// Provider untuk update kategori
final updateCategoryProvider =
    FutureProvider.family<CategoryEntity, CategoryEntity>((
      ref,
      category,
    ) async {
      final repository = await ref.watch(categoryRepositoryProvider.future);
      return repository.updateCategory(category);
    });

/// Provider untuk delete kategori
final deleteCategoryProvider = FutureProvider.family<void, String>((
  ref,
  categoryId,
) async {
  final repository = await ref.watch(categoryRepositoryProvider.future);
  return repository.deleteCategory(categoryId);
});
