import 'package:sisasaku/features/export/domain/entities/export_entity.dart';
import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';

/// Abstract repository untuk Export
abstract class ExportRepository {
  /// Ekspor transaksi ke PDF
  Future<ExportEntity> exportToPdf({
    required DateTime startDate,
    required DateTime endDate,
    required List<TransactionEntity> transactions,
  });

  /// Ekspor transaksi ke CSV
  Future<ExportEntity> exportToCsv({
    required DateTime startDate,
    required DateTime endDate,
    required List<TransactionEntity> transactions,
  });

  /// Get riwayat ekspor
  Future<List<ExportEntity>> getExportHistory();
}
