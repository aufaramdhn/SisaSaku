import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/core/errors/exceptions.dart';
import 'package:sisasaku/features/transaction/data/datasources/transaction_local_datasource.dart';
import 'package:sisasaku/features/transaction/data/models/transaction_model.dart';
import 'package:sisasaku/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';

/// Fake datasource that stores transactions in memory.
/// Mirrors the implementation in `transaction_repository_impl_test.dart`
/// so the property test can exercise the real repository mapping logic
/// without requiring an Isar instance.
class FakeTransactionLocalDatasource implements TransactionLocalDatasource {
  final Map<String, TransactionModel> _store = {};

  @override
  Isar get isar => throw UnimplementedError('Isar not used in fake');

  @override
  Future<List<TransactionModel>> getTransactions() async =>
      _store.values.toList();

  @override
  Future<TransactionModel?> getTransactionById(String id) async => _store[id];

  @override
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _store.values
        .where(
          (t) =>
              t.tanggal != null &&
              !t.tanggal!.isBefore(startDate) &&
              !t.tanggal!.isAfter(endDate),
        )
        .toList();
  }

  @override
  Future<List<TransactionModel>> getMonthlyTransactions(
    int month,
    int year,
  ) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
    return getTransactionsByDateRange(startDate, endDate);
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    final id = transaction.id;
    if (id == null) {
      throw DatabaseException(message: 'Transaction id is null');
    }
    _store[id] = transaction;
    return transaction;
  }

  @override
  Future<TransactionModel> updateTransaction(
    TransactionModel transaction,
  ) async {
    return addTransaction(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _store.remove(id);
  }

  @override
  Future<List<TransactionModel>> getUnsyncedTransactions() async {
    return _store.values.where((t) => t.syncStatus == false).toList();
  }

  @override
  Stream<List<TransactionModel>> watchTransactions() =>
      Stream.value(_store.values.toList());

  @override
  Stream<List<TransactionModel>> watchTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final filtered = _store.values
        .where(
          (t) =>
              t.tanggal != null &&
              !t.tanggal!.isBefore(startDate) &&
              !t.tanggal!.isAfter(endDate),
        )
        .toList();
    return Stream.value(filtered);
  }

  @override
  Future<void> markTransactionAsSynced(String id) async {
    final existing = _store[id];
    if (existing != null) {
      _store[id] = existing.copyWith(syncStatus: true);
    }
  }
}

/// Smart generator for TransactionEntity values.
///
/// Constraints reflect the input space the repository is expected to
/// handle in practice:
/// - `id` is a non-empty string (UUID-like length, alphanumeric).
/// - `nominal` is a finite, non-negative double rounded to 2 decimals
///   (matching IDR currency precision used in the app).
/// - `jenis` covers both TransactionType values.
/// - `tanggal`, `createdAt`, `updatedAt` are within a wide but realistic
///   range (1970..2100) so DateTime equality is well-defined.
/// - `idKategori` is a non-empty string.
/// - `deskripsi` is sometimes null and sometimes a non-empty string,
///   exercising the nullable field.
/// - `syncStatus` is a random bool.
TransactionEntity _arbitraryEntity(Random rng, int index) {
  // Deterministic id derived from the index keeps each entity unique
  // and easy to surface in counter-examples.
  final idSuffix = rng.nextInt(1 << 32).toRadixString(16).padLeft(8, '0');
  final id = 'tx-$index-$idSuffix';

  // Nominal: 0.00 .. 100_000_000.00 with 2 decimal places.
  final nominal = (rng.nextDouble() * 100000000 * 100).roundToDouble() / 100.0;

  final jenis = rng.nextBool() ? TransactionType.income : TransactionType.expense;

  // Date range 1970-01-01 .. 2100-12-31 in milliseconds.
  const minMs = 0; // 1970-01-01
  final maxMs = DateTime(2100, 12, 31, 23, 59, 59).millisecondsSinceEpoch;
  DateTime randomDate() {
    final ms = minMs + (rng.nextDouble() * (maxMs - minMs)).floor();
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  final tanggal = randomDate();
  final createdAt = randomDate();
  final updatedAt = randomDate();

  final idKategori = 'cat-${rng.nextInt(1 << 16).toRadixString(16)}';

  // 30% chance of null deskripsi to exercise the nullable branch.
  String? deskripsi;
  if (rng.nextDouble() < 0.7) {
    final words = <String>[];
    final wordCount = rng.nextInt(5) + 1;
    for (var i = 0; i < wordCount; i++) {
      words.add('w${rng.nextInt(1000)}');
    }
    deskripsi = words.join(' ');
  }

  final syncStatus = rng.nextBool();

  return TransactionEntity(
    id: id,
    nominal: nominal,
    jenis: jenis,
    tanggal: tanggal,
    idKategori: idKategori,
    deskripsi: deskripsi,
    createdAt: createdAt,
    updatedAt: updatedAt,
    syncStatus: syncStatus,
  );
}

void main() {
  // Fixed seed for reproducibility — any failure surfaces a deterministic
  // counter-example that can be reproduced by re-running the test.
  const seed = 0xC0FFEE;
  const sampleCount = 300;

  group('Property 2: Transaction model-entity mapping round-trip', () {
    test(
      'for any valid TransactionEntity, entity → model → entity preserves '
      'id, nominal, jenis, tanggal, idKategori, deskripsi, syncStatus '
      '(also verifies createdAt and updatedAt) over $sampleCount samples '
      '(seed=$seed)',
      () async {
        final rng = Random(seed);

        for (var i = 0; i < sampleCount; i++) {
          final original = _arbitraryEntity(rng, i);

          // Fresh repository per sample so a single store doesn't mask
          // mapping bugs by aliasing the same instance across iterations.
          final fakeDatasource = FakeTransactionLocalDatasource();
          final repository = TransactionRepositoryImpl(fakeDatasource);

          // Round-trip: addTransaction performs entity → model, then
          // getTransactionById performs model → entity.
          await repository.addTransaction(original);
          final roundTripped = await repository.getTransactionById(original.id);

          final reason = 'Sample #$i (seed=$seed) original=$original '
              'roundTripped=$roundTripped';

          expect(roundTripped, isNotNull, reason: reason);
          expect(roundTripped!.id, original.id, reason: reason);
          expect(roundTripped.nominal, original.nominal, reason: reason);
          expect(roundTripped.jenis, original.jenis, reason: reason);
          expect(roundTripped.tanggal, original.tanggal, reason: reason);
          expect(roundTripped.idKategori, original.idKategori, reason: reason);
          expect(roundTripped.deskripsi, original.deskripsi, reason: reason);
          expect(roundTripped.syncStatus, original.syncStatus, reason: reason);
          expect(roundTripped.createdAt, original.createdAt, reason: reason);
          expect(roundTripped.updatedAt, original.updatedAt, reason: reason);
        }
      },
    );
  });

  // **Validates: Requirements 5.2**
}
