import 'package:sisasaku/features/splitbill/data/datasources/split_bill_local_datasource.dart';
import 'package:sisasaku/features/splitbill/data/models/split_bill_model.dart';
import 'package:sisasaku/features/splitbill/domain/entities/split_bill_entity.dart';
import 'package:sisasaku/features/splitbill/domain/repositories/split_bill_repository.dart';

class SplitBillRepositoryImpl implements SplitBillRepository {
  final SplitBillLocalDatasource localDatasource;

  SplitBillRepositoryImpl(this.localDatasource);

  SplitBillEntity _modelToEntity(SplitBillModel model) {
    return SplitBillEntity(
      id: model.id ?? '',
      title: model.title ?? '',
      total: model.total ?? 0,
      isEqualSplit: model.isEqualSplit,
      participantNames: model.participantNames,
      participantAmounts: model.participantAmounts,
      paidParticipantNames: model.paidParticipantNames,
      isSettled: model.isSettled,
      createdAt: model.createdAt ?? DateTime.now(),
      updatedAt: model.updatedAt ?? DateTime.now(),
      syncStatus: model.syncStatus,
    );
  }

  SplitBillModel _entityToModel(SplitBillEntity entity) {
    return SplitBillModel(
      id: entity.id,
      title: entity.title,
      total: entity.total,
      isEqualSplit: entity.isEqualSplit,
      participantNames: entity.participantNames,
      participantAmounts: entity.participantAmounts,
      paidParticipantNames: entity.paidParticipantNames,
      isSettled: entity.isSettled,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
    );
  }

  @override
  Future<SplitBillEntity> addSplitBill(SplitBillEntity splitBill) async {
    return _modelToEntity(
      await localDatasource.addSplitBill(_entityToModel(splitBill)),
    );
  }

  @override
  Future<void> deleteSplitBill(String id) =>
      localDatasource.deleteSplitBill(id);

  @override
  Future<SplitBillEntity?> getSplitBillById(String id) async {
    final model = await localDatasource.getSplitBillById(id);
    return model == null ? null : _modelToEntity(model);
  }

  @override
  Future<List<SplitBillEntity>> getSplitBills() async {
    final models = await localDatasource.getSplitBills();
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<List<SplitBillEntity>> getUnsyncedSplitBills() async {
    final models = await localDatasource.getUnsyncedSplitBills();
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<SplitBillEntity> markParticipantPaid(
    String id,
    String participantName,
    bool isPaid,
  ) async {
    return _modelToEntity(
      await localDatasource.markParticipantPaid(id, participantName, isPaid),
    );
  }

  @override
  Future<SplitBillEntity> updateSplitBill(SplitBillEntity splitBill) async {
    return _modelToEntity(
      await localDatasource.updateSplitBill(_entityToModel(splitBill)),
    );
  }

  @override
  Stream<List<SplitBillEntity>> watchSplitBills() {
    return localDatasource.watchSplitBills().map(
      (models) => models.map(_modelToEntity).toList(),
    );
  }
}
