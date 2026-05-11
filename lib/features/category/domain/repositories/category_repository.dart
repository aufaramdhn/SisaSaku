import 'package:sisasaku/features/category/domain/entities/category_entity.dart';

/// Abstract repository untuk Category
abstract class CategoryRepository {
  /// Get semua kategori
  Future<List<CategoryEntity>> getCategories();

  /// Get kategori by ID
  Future<CategoryEntity?> getCategoryById(String id);

  /// Add kategori baru
  Future<CategoryEntity> addCategory(CategoryEntity category);

  /// Update kategori
  Future<CategoryEntity> updateCategory(CategoryEntity category);

  /// Delete kategori
  Future<void> deleteCategory(String id);

  /// Get kategori yang belum tersinkronisasi
  Future<List<CategoryEntity>> getUnsyncedCategories();
}
