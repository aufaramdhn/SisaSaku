import 'package:sisasaku/core/errors/exceptions.dart';
import 'package:sisasaku/features/budget/data/datasources/budget_local_datasource.dart';
import 'package:sisasaku/features/budget/data/models/budget_model.dart';
import 'package:sisasaku/features/budget/domain/entities/budget_entity.dart';
import 'package:sisasaku/features/budget/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDatasource localDatasource;

  BudgetRepositoryImpl(this.localDatasource);

  BudgetEntity _modelToEntity(BudgetModel model) {
    return BudgetEntity(
      id: model.id ?? '',
      idKategori: model.idKategori ?? '',
      namaKategori: model.namaKategori ?? '',
      limit: model.limit ?? 0,
      period: model.period ?? 'monthly',
      month: model.month ?? DateTime.now().month,
      year: model.year ?? DateTime.now().year,
      createdAt: model.createdAt ?? DateTime.now(),
      updatedAt: model.updatedAt ?? DateTime.now(),
      syncStatus: model.syncStatus,
    );
  }

  BudgetModel _entityToModel(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      idKategori: entity.idKategori,
      namaKategori: entity.namaKategori,
      limit: entity.limit,
      period: entity.period,
      month: entity.month,
      year: entity.year,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
    );
  }

  @override
  Future<BudgetEntity> addBudget(BudgetEntity budget) async {
    try {
      return _modelToEntity(
        await localDatasource.addBudget(_entityToModel(budget)),
      );
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<void> deleteBudget(String id) => localDatasource.deleteBudget(id);

  @override
  Future<BudgetEntity?> getBudgetById(String id) async {
    final model = await localDatasource.getBudgetById(id);
    return model == null ? null : _modelToEntity(model);
  }

  @override
  Future<List<BudgetEntity>> getBudgets() async {
    final models = await localDatasource.getBudgets();
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<List<BudgetEntity>> getUnsyncedBudgets() async {
    final models = await localDatasource.getUnsyncedBudgets();
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<BudgetEntity> updateBudget(BudgetEntity budget) async {
    return _modelToEntity(
      await localDatasource.updateBudget(_entityToModel(budget)),
    );
  }

  @override
  Stream<List<BudgetEntity>> watchBudgets() {
    return localDatasource.watchBudgets().map(
      (models) => models.map(_modelToEntity).toList(),
    );
  }
}
