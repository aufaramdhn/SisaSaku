import 'package:isar/isar.dart';
import 'package:sisasaku/core/services/sync_service.dart';
import 'package:sisasaku/features/transaction/data/models/transaction_model.dart';
import 'package:sisasaku/core/errors/exceptions.dart';

/// Local datasource untuk Transaction (Isar)
class TransactionLocalDatasource {
  final Isar isar;

  TransactionLocalDatasource(this.isar);

  /// Get semua transaksi
  Future<List<TransactionModel>> getTransactions() async {
    try {
      return await isar.transactionModels.where().sortByTanggalDesc().findAll();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil transaksi: $e');
    }
  }

  /// Get transaksi by ID
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      return await isar.transactionModels.where().idEqualTo(id).findFirst();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil transaksi: $e');
    }
  }

  /// Get transaksi dalam range tanggal
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await isar.transactionModels
          .where()
          .tanggalBetween(startDate, endDate)
          .sortByTanggalDesc()
          .findAll();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil transaksi: $e');
    }
  }

  /// Get transaksi bulan ini
  Future<List<TransactionModel>> getMonthlyTransactions(
    int month,
    int year,
  ) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
      return getTransactionsByDateRange(startDate, endDate);
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil transaksi bulanan: $e');
    }
  }

  /// Add transaksi
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    try {
      await isar.writeTxn(() async {
        await isar.transactionModels.put(transaction);
      });
      return transaction;
    } catch (e) {
      throw DatabaseException(message: 'Gagal menambah transaksi: $e');
    }
  }

  /// Update transaksi
  Future<TransactionModel> updateTransaction(
    TransactionModel transaction,
  ) async {
    try {
      final updated = transaction.copyWith(
        updatedAt: DateTime.now(),
        syncStatus: false,
      )..isarId = transaction.isarId;
      await isar.writeTxn(() async {
        await isar.transactionModels.put(updated);
      });
      return updated;
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengupdate transaksi: $e');
    }
  }

  /// Delete transaksi
  Future<void> deleteTransaction(String id) async {
    try {
      final transaction = await getTransactionById(id);
      if (transaction != null) {
        await SyncService.queueDelete(SyncService.tableTransactions, id);
        await isar.writeTxn(() async {
          await isar.transactionModels.delete(transaction.isarId!);
        });
      }
    } catch (e) {
      throw DatabaseException(message: 'Gagal menghapus transaksi: $e');
    }
  }

  /// Get transaksi yang belum tersinkronisasi
  Future<List<TransactionModel>> getUnsyncedTransactions() async {
    try {
      final transactions = await isar.transactionModels.where().findAll();
      return transactions
          .where((transaction) => transaction.syncStatus == false)
          .toList();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil transaksi: $e');
    }
  }

  /// Mark transaksi as synced
  Future<void> markTransactionAsSynced(String id) async {
    try {
      final transaction = await getTransactionById(id);
      if (transaction != null) {
        await updateTransaction(transaction.copyWith(syncStatus: true));
      }
    } catch (e) {
      throw DatabaseException(message: 'Gagal mensinkronisasi transaksi: $e');
    }
  }

  /// Watch semua transaksi (real-time stream)
  Stream<List<TransactionModel>> watchTransactions() {
    try {
      return isar.transactionModels.where().watch(fireImmediately: true).map((
        transactions,
      ) {
        transactions.sort(
          (a, b) => (b.tanggal ?? DateTime.now()).compareTo(
            a.tanggal ?? DateTime.now(),
          ),
        );
        return transactions;
      });
    } catch (e) {
      throw DatabaseException(message: 'Gagal memantau transaksi: $e');
    }
  }

  /// Watch transaksi dalam range tanggal (real-time stream)
  Stream<List<TransactionModel>> watchTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      return isar.transactionModels.where().watch(fireImmediately: true).map((
        transactions,
      ) {
        final filtered =
            transactions
                .where(
                  (t) =>
                      t.tanggal != null &&
                      t.tanggal!.isAfter(startDate) &&
                      t.tanggal!.isBefore(endDate),
                )
                .toList()
              ..sort(
                (a, b) => (b.tanggal ?? DateTime.now()).compareTo(
                  a.tanggal ?? DateTime.now(),
                ),
              );
        return filtered;
      });
    } catch (e) {
      throw DatabaseException(message: 'Gagal memantau transaksi: $e');
    }
  }
}
