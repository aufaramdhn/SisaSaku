import 'package:sisasaku/features/bill/data/datasources/bill_local_datasource.dart';
import 'package:sisasaku/features/bill/data/models/bill_model.dart';
import 'package:sisasaku/features/bill/domain/entities/bill_entity.dart';
import 'package:sisasaku/features/bill/domain/repositories/bill_repository.dart';
import 'package:sisasaku/core/errors/exceptions.dart';
import 'package:sisasaku/core/enums.dart';

/// Repository implementation untuk Bill
class BillRepositoryImpl extends BillRepository {
  final BillLocalDatasource localDatasource;

  BillRepositoryImpl(this.localDatasource);

  /// Convert model to entity
  BillEntity _modelToEntity(BillModel model) {
    return BillEntity(
      id: model.id ?? '',
      nama: model.nama ?? '',
      nominal: model.nominal,
      tanggalJatuhTempo: model.tanggalJatuhTempo ?? DateTime.now(),
      waktuPengingat: model.waktuPengingat ?? DateTime.now(),
      status: BillStatus.fromJson(model.status ?? BillStatus.upcoming.label),
      tanggalPembayaran: model.tanggalPembayaran,
      deskripsi: model.deskripsi,
      createdAt: model.createdAt ?? DateTime.now(),
      updatedAt: model.updatedAt ?? DateTime.now(),
      syncStatus: model.syncStatus,
    );
  }

  /// Convert entity to model
  BillModel _entityToModel(BillEntity entity) {
    return BillModel(
      id: entity.id,
      nama: entity.nama,
      nominal: entity.nominal,
      tanggalJatuhTempo: entity.tanggalJatuhTempo,
      waktuPengingat: entity.waktuPengingat,
      status: entity.status.label,
      tanggalPembayaran: entity.tanggalPembayaran,
      deskripsi: entity.deskripsi,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
    );
  }

  @override
  Future<List<BillEntity>> getBills() async {
    try {
      final models = await localDatasource.getBills();
      return models.map(_modelToEntity).toList();
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<BillEntity?> getBillById(String id) async {
    try {
      final model = await localDatasource.getBillById(id);
      return model != null ? _modelToEntity(model) : null;
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<List<BillEntity>> getBillsByStatus(BillStatus status) async {
    try {
      final models = await localDatasource.getBillsByStatus(status.label);
      return models.map(_modelToEntity).toList();
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<List<BillEntity>> getUpcomingBills({int limit = 5}) async {
    try {
      final models = await localDatasource.getUpcomingBills(limit: limit);
      return models.map(_modelToEntity).toList();
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<List<BillEntity>> getOverdueBills() async {
    try {
      final models = await localDatasource.getOverdueBills();
      return models.map(_modelToEntity).toList();
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<BillEntity> addBill(BillEntity bill) async {
    try {
      final model = _entityToModel(bill);
      final result = await localDatasource.addBill(model);
      return _modelToEntity(result);
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<BillEntity> updateBill(BillEntity bill) async {
    try {
      final model = _entityToModel(bill);
      final result = await localDatasource.updateBill(model);
      return _modelToEntity(result);
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<BillEntity> updateBillStatus(
    String billId,
    BillStatus newStatus,
  ) async {
    try {
      final result = await localDatasource.updateBillStatus(
        billId,
        newStatus.label,
      );
      return _modelToEntity(result);
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<void> deleteBill(String id) async {
    try {
      await localDatasource.deleteBill(id);
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<List<BillEntity>> getUnsyncedBills() async {
    try {
      final models = await localDatasource.getUnsyncedBills();
      return models.map(_modelToEntity).toList();
    } on DatabaseException {
      rethrow;
    }
  }
}
