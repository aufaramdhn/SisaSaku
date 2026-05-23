import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/providers/isar_provider.dart';
import 'package:sisasaku/features/transaction/data/datasources/transaction_local_datasource.dart';
import 'package:sisasaku/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';
import 'package:sisasaku/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:sisasaku/core/enums.dart';

/// Provider untuk TransactionLocalDatasource
final transactionLocalDatasourceProvider =
    FutureProvider<TransactionLocalDatasource>((ref) async {
      final isar = ref.watch(isarProvider);
      return TransactionLocalDatasource(isar);
    });

/// Provider untuk TransactionRepository
final transactionRepositoryProvider = FutureProvider<TransactionRepository>((
  ref,
) async {
  final datasource = await ref.watch(transactionLocalDatasourceProvider.future);
  return TransactionRepositoryImpl(datasource);
});

/// Provider untuk daftar transaksi
final transactionsProvider = StreamProvider<List<TransactionEntity>>((ref) {
  final repositoryAsync = ref.watch(transactionRepositoryProvider);
  return repositoryAsync.when(
    data: (repo) => repo.watchTransactions(),
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.error(err, stack),
  );
});

/// Provider untuk transaksi by ID
final transactionByIdProvider =
    FutureProvider.family<TransactionEntity?, String>((
      ref,
      transactionId,
    ) async {
      final repository = await ref.watch(transactionRepositoryProvider.future);
      return repository.getTransactionById(transactionId);
    });

/// Provider untuk transaksi bulan ini
final monthlyTransactionsProvider =
    StreamProvider.family<List<TransactionEntity>, (int, int)>((
      ref,
      dateRange,
    ) {
      final (month, year) = dateRange;
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
      final repositoryAsync = ref.watch(transactionRepositoryProvider);
      return repositoryAsync.when(
        data: (repo) => repo.watchTransactionsByDateRange(startDate, endDate),
        loading: () => Stream.value([]),
        error: (err, stack) => Stream.error(err, stack),
      );
    });

/// Provider untuk total pemasukan bulan ini
final monthlyIncomeProvider = StreamProvider.family<double, (int, int)>((
  ref,
  dateRange,
) async* {
  final transactions = await ref.watch(
    monthlyTransactionsProvider(dateRange).future,
  );
  final income = transactions
      .where((t) => t.jenis == TransactionType.income)
      .fold<double>(0, (sum, t) => sum + t.nominal);
  yield income;
});

/// Provider untuk total pengeluaran bulan ini
final monthlyExpenseProvider = StreamProvider.family<double, (int, int)>((
  ref,
  dateRange,
) async* {
  final transactions = await ref.watch(
    monthlyTransactionsProvider(dateRange).future,
  );
  final expense = transactions
      .where((t) => t.jenis == TransactionType.expense)
      .fold<double>(0, (sum, t) => sum + t.nominal);
  yield expense;
});

/// Provider untuk add transaksi
final addTransactionProvider =
    FutureProvider.family<TransactionEntity, TransactionEntity>((
      ref,
      transaction,
    ) async {
      final repository = await ref.watch(transactionRepositoryProvider.future);
      return repository.addTransaction(transaction);
    });

/// Provider untuk update transaksi
final updateTransactionProvider =
    FutureProvider.family<TransactionEntity, TransactionEntity>((
      ref,
      transaction,
    ) async {
      final repository = await ref.watch(transactionRepositoryProvider.future);
      return repository.updateTransaction(transaction);
    });

/// Provider untuk delete transaksi
final deleteTransactionProvider = FutureProvider.family<void, String>((
  ref,
  transactionId,
) async {
  final repository = await ref.watch(transactionRepositoryProvider.future);
  return repository.deleteTransaction(transactionId);
});
