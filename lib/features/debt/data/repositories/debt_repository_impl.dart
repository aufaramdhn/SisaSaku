import 'package:sisasaku/features/debt/data/datasources/debt_local_datasource.dart';
import 'package:sisasaku/features/debt/data/models/debt_model.dart';
import 'package:sisasaku/features/debt/domain/entities/debt_entity.dart';
import 'package:sisasaku/features/debt/domain/repositories/debt_repository.dart';

class DebtRepositoryImpl implements DebtRepository {
  final DebtLocalDatasource localDatasource;

  DebtRepositoryImpl(this.localDatasource);

  DebtEntity _modelToEntity(DebtModel model) {
    return DebtEntity(
      id: model.id ?? '',
      person: model.person ?? '',
      amount: model.amount ?? 0,
      date: model.date ?? DateTime.now(),
      notes: model.notes,
      type: model.type ?? 'i_owe',
      isSettled: model.isSettled,
      settledAt: model.settledAt,
      createdAt: model.createdAt ?? DateTime.now(),
      updatedAt: model.updatedAt ?? DateTime.now(),
      syncStatus: model.syncStatus,
    );
  }

  DebtModel _entityToModel(DebtEntity entity) {
    return DebtModel(
      id: entity.id,
      person: entity.person,
      amount: entity.amount,
      date: entity.date,
      notes: entity.notes,
      type: entity.type,
      isSettled: entity.isSettled,
      settledAt: entity.settledAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
    );
  }

  @override
  Future<DebtEntity> addDebt(DebtEntity debt) async {
    return _modelToEntity(await localDatasource.addDebt(_entityToModel(debt)));
  }

  @override
  Future<void> deleteDebt(String id) => localDatasource.deleteDebt(id);

  @override
  Future<DebtEntity?> getDebtById(String id) async {
    final model = await localDatasource.getDebtById(id);
    return model == null ? null : _modelToEntity(model);
  }

  @override
  Future<List<DebtEntity>> getDebts() async {
    final models = await localDatasource.getDebts();
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<List<DebtEntity>> getUnsyncedDebts() async {
    final models = await localDatasource.getUnsyncedDebts();
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<DebtEntity> updateDebt(DebtEntity debt) async {
    return _modelToEntity(
      await localDatasource.updateDebt(_entityToModel(debt)),
    );
  }

  @override
  Future<DebtEntity> updateDebtSettlement(String id, bool isSettled) async {
    return _modelToEntity(
      await localDatasource.updateDebtSettlement(id, isSettled),
    );
  }

  @override
  Stream<List<DebtEntity>> watchDebts() {
    return localDatasource.watchDebts().map(
      (models) => models.map(_modelToEntity).toList(),
    );
  }
}
