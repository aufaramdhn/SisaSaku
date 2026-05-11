import 'package:isar/isar.dart';
import 'package:sisasaku/features/category/data/models/category_model.dart';
import 'package:sisasaku/core/errors/exceptions.dart';

/// Local datasource untuk Category (Isar)
class CategoryLocalDatasource {
  final Isar isar;

  CategoryLocalDatasource(this.isar);

  /// Get semua kategori
  Future<List<CategoryModel>> getCategories() async {
    try {
      return await isar.categoryModels.where().findAll();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil kategori: $e');
    }
  }

  /// Get kategori by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      return await isar.categoryModels.where().idEqualTo(id).findFirst();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil kategori: $e');
    }
  }

  /// Add kategori
  Future<CategoryModel> addCategory(CategoryModel category) async {
    try {
      await isar.writeTxn(() async {
        await isar.categoryModels.put(category);
      });
      return category;
    } catch (e) {
      throw DatabaseException(message: 'Gagal menambah kategori: $e');
    }
  }

  /// Update kategori
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final updated = category.copyWith(updatedAt: DateTime.now());
      await isar.writeTxn(() async {
        await isar.categoryModels.put(updated);
      });
      return updated;
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengupdate kategori: $e');
    }
  }

  /// Delete kategori
  Future<void> deleteCategory(String id) async {
    try {
      final category = await isar.categoryModels
          .where()
          .idEqualTo(id)
          .findFirst();
      if (category != null) {
        await isar.writeTxn(() async {
          await isar.categoryModels.delete(category.isarId!);
        });
      }
    } catch (e) {
      throw DatabaseException(message: 'Gagal menghapus kategori: $e');
    }
  }

  /// Get kategori yang belum tersinkronisasi
  Future<List<CategoryModel>> getUnsyncedCategories() async {
    try {
      final categories = await isar.categoryModels.where().findAll();
      return categories
          .where((category) => category.syncStatus == false)
          .toList();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil kategori: $e');
    }
  }

  /// Mark kategori as synced
  Future<void> markCategoryAsSynced(String id) async {
    try {
      final category = await getCategoryById(id);
      if (category != null) {
        await updateCategory(category.copyWith(syncStatus: true));
      }
    } catch (e) {
      throw DatabaseException(message: 'Gagal mensinkronisasi kategori: $e');
    }
  }
}
