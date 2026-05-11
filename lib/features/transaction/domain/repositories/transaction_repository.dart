import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';

/// Abstract repository untuk Transaction
abstract class TransactionRepository {
  /// Get semua transaksi
  Future<List<TransactionEntity>> getTransactions();

  /// Get transaksi by ID
  Future<TransactionEntity?> getTransactionById(String id);

  /// Get transaksi dalam range tanggal
  Future<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get transaksi bulan ini
  Future<List<TransactionEntity>> getMonthlyTransactions(int month, int year);

  /// Add transaksi baru
  Future<TransactionEntity> addTransaction(TransactionEntity transaction);

  /// Update transaksi
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction);

  /// Delete transaksi
  Future<void> deleteTransaction(String id);

  /// Get transaksi yang belum tersinkronisasi
  Future<List<TransactionEntity>> getUnsyncedTransactions();
}
