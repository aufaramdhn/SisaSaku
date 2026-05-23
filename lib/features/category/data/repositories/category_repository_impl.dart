import 'package:sisasaku/features/category/data/datasources/category_local_datasource.dart';
import 'package:sisasaku/features/category/data/models/category_model.dart';
import 'package:sisasaku/features/category/domain/entities/category_entity.dart';
import 'package:sisasaku/features/category/domain/repositories/category_repository.dart';
import 'package:sisasaku/core/errors/exceptions.dart';

/// Repository implementation untuk Category
class CategoryRepositoryImpl extends CategoryRepository {
  final CategoryLocalDatasource localDatasource;

  CategoryRepositoryImpl(this.localDatasource);

  /// Convert model to entity
  CategoryEntity _modelToEntity(CategoryModel model) {
    return CategoryEntity(
      id: model.id ?? '',
      nama: model.nama ?? '',
      ikon: model.ikon ?? '',
      warna: model.warna ?? '',
      createdAt: model.createdAt ?? DateTime.now(),
      updatedAt: model.updatedAt ?? DateTime.now(),
      syncStatus: model.syncStatus,
    );
  }

  /// Convert entity to model
  CategoryModel _entityToModel(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      nama: entity.nama,
      ikon: entity.ikon,
      warna: entity.warna,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
    );
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      final models = await localDatasource.getCategories();
      return models.map(_modelToEntity).toList();
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<CategoryEntity?> getCategoryById(String id) async {
    try {
      final model = await localDatasource.getCategoryById(id);
      return model != null ? _modelToEntity(model) : null;
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<CategoryEntity> addCategory(CategoryEntity category) async {
    try {
      final model = _entityToModel(category);
      final result = await localDatasource.addCategory(model);
      return _modelToEntity(result);
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    try {
      final model = _entityToModel(category);
      final result = await localDatasource.updateCategory(model);
      return _modelToEntity(result);
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await localDatasource.deleteCategory(id);
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<List<CategoryEntity>> getUnsyncedCategories() async {
    try {
      final models = await localDatasource.getUnsyncedCategories();
      return models.map(_modelToEntity).toList();
    } on DatabaseException {
      rethrow;
    }
  }

  /// Stream semua kategori (real-time)
  @override
  Stream<List<CategoryEntity>> watchCategories() {
    try {
      return localDatasource.watchCategories().map(
        (models) => models.map(_modelToEntity).toList(),
      );
    } on DatabaseException {
      rethrow;
    }
  }
}
