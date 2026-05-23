import 'package:sisasaku/core/errors/exceptions.dart';
import 'package:sisasaku/features/export/data/datasources/export_local_datasource.dart';
import 'package:sisasaku/features/export/data/models/export_config_model.dart';
import 'package:sisasaku/features/export/domain/entities/export_entity.dart';
import 'package:sisasaku/features/export/domain/repositories/export_repository.dart';
import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';

/// Repository implementation untuk Export
class ExportRepositoryImpl implements ExportRepository {
  final ExportLocalDatasource localDatasource;

  ExportRepositoryImpl(this.localDatasource);

  /// Convert model to entity
  ExportEntity _modelToEntity(ExportConfigModel model) {
    return model.toEntity();
  }

  @override
  Future<ExportEntity> exportToPdf({
    required DateTime startDate,
    required DateTime endDate,
    required List<TransactionEntity> transactions,
  }) async {
    try {
      final model = await localDatasource.generatePdf(
        startDate: startDate,
        endDate: endDate,
        transactions: transactions,
      );
      return _modelToEntity(model);
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<ExportEntity> exportToCsv({
    required DateTime startDate,
    required DateTime endDate,
    required List<TransactionEntity> transactions,
  }) async {
    try {
      final model = await localDatasource.generateCsv(
        startDate: startDate,
        endDate: endDate,
        transactions: transactions,
      );
      return _modelToEntity(model);
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<List<ExportEntity>> getExportHistory() async {
    try {
      final models = await localDatasource.getExportHistory();
      return models.map(_modelToEntity).toList();
    } on DatabaseException {
      rethrow;
    }
  }
}
