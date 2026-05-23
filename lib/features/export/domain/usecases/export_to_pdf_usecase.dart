import 'package:sisasaku/features/export/domain/entities/export_entity.dart';
import 'package:sisasaku/features/export/domain/repositories/export_repository.dart';
import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';

/// Use case untuk mengekspor transaksi ke PDF
class ExportToPdfUsecase {
  final ExportRepository repository;

  ExportToPdfUsecase({required this.repository});

  Future<ExportEntity> call({
    required DateTime startDate,
    required DateTime endDate,
    required List<TransactionEntity> transactions,
  }) {
    return repository.exportToPdf(
      startDate: startDate,
      endDate: endDate,
      transactions: transactions,
    );
  }
}
