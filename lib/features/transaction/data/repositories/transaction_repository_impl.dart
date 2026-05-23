import 'package:sisasaku/features/transaction/data/datasources/transaction_local_datasource.dart';
import 'package:sisasaku/features/transaction/data/models/transaction_model.dart';
import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';
import 'package:sisasaku/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:sisasaku/core/errors/exceptions.dart';
import 'package:sisasaku/core/enums.dart';

/// Repository implementation untuk Transaction
class TransactionRepositoryImpl extends TransactionRepository {
  final TransactionLocalDatasource localDatasource;

  TransactionRepositoryImpl(this.localDatasource);

  /// Convert model to entity
  TransactionEntity _modelToEntity(TransactionModel model) {
    return TransactionEntity(
      id: model.id ?? '',
      nominal: model.nominal ?? 0,
      jenis: TransactionType.fromJson(
        model.jenis ?? TransactionType.expense.label,
      ),
      tanggal: model.tanggal ?? DateTime.now(),
      idKategori: model.idKategori ?? '',
      deskripsi: model.deskripsi,
      createdAt: model.createdAt ?? DateTime.now(),
      updatedAt: model.updatedAt ?? DateTime.now(),
      syncStatus: model.syncStatus,
    );
  }

  /// Convert entity to model
  TransactionModel _entityToModel(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      nominal: entity.nominal,
      jenis: entity.jenis.label,
      tanggal: entity.tanggal,
      idKategori: entity.idKategori,
      deskripsi: entity.deskripsi,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
    );
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    try {
      final models = await localDatasource.getTransactions();
      return models.map(_modelToEntity).toList();
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<TransactionEntity?> getTransactionById(String id) async {
    try {
      final model = await localDatasource.getTransactionById(id);
      return model != null ? _modelToEntity(model) : null;
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final models = await localDatasource.getTransactionsByDateRange(
        startDate,
        endDate,
      );
      return models.map(_modelToEntity).toList();
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<List<TransactionEntity>> getMonthlyTransactions(
    int month,
    int year,
  ) async {
    try {
      final models = await localDatasource.getMonthlyTransactions(month, year);
      return models.map(_modelToEntity).toList();
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<TransactionEntity> addTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = _entityToModel(transaction);
      final result = await localDatasource.addTransaction(model);
      return _modelToEntity(result);
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<TransactionEntity> updateTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = _entityToModel(transaction);
      final result = await localDatasource.updateTransaction(model);
      return _modelToEntity(result);
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await localDatasource.deleteTransaction(id);
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<List<TransactionEntity>> getUnsyncedTransactions() async {
    try {
      final models = await localDatasource.getUnsyncedTransactions();
      return models.map(_modelToEntity).toList();
    } on DatabaseException {
      rethrow;
    }
  }

  /// Stream semua transaksi (real-time)
  @override
  Stream<List<TransactionEntity>> watchTransactions() {
    try {
      return localDatasource.watchTransactions().map(
        (models) => models.map(_modelToEntity).toList(),
      );
    } on DatabaseException {
      rethrow;
    }
  }

  /// Stream transaksi dalam range tanggal (real-time)
  @override
  Stream<List<TransactionEntity>> watchTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      return localDatasource
          .watchTransactionsByDateRange(startDate, endDate)
          .map((models) => models.map(_modelToEntity).toList());
    } on DatabaseException {
      rethrow;
    }
  }
}
