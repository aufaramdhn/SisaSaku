import 'dart:io';
import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisasaku/features/transaction/data/datasources/transaction_local_datasource.dart';
import 'package:sisasaku/features/transaction/data/models/transaction_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Isar isar;
  late TransactionLocalDatasource datasource;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final localAppData = Platform.environment['LOCALAPPDATA'];
    final libraryPath =
        '$localAppData\\Pub\\Cache\\hosted\\pub.dev\\isar_flutter_libs-3.1.0+1\\windows\\isar.dll';
    await Isar.initializeIsarCore(libraries: {Abi.current(): libraryPath});
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('sisasaku_tx_datasource_');
    isar = await Isar.open(
      [TransactionModelSchema],
      directory: tempDir.path,
    );
    datasource = TransactionLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  TransactionModel createTransaction({
    String? id,
    double nominal = 50000,
    String jenis = 'pengeluaran',
    DateTime? tanggal,
    String idKategori = 'food',
    String? deskripsi,
    bool syncStatus = false,
  }) {
    return TransactionModel(
      id: id,
      nominal: nominal,
      jenis: jenis,
      tanggal: tanggal ?? DateTime(2026, 5, 15),
      idKategori: idKategori,
      deskripsi: deskripsi,
      syncStatus: syncStatus,
    );
  }

  group('addTransaction', () {
    test('adds a transaction and returns it with a generated id', () async {
      final transaction = createTransaction(deskripsi: 'Makan siang');

      final result = await datasource.addTransaction(transaction);

      expect(result.id, isNotNull);
      expect(result.id, isNotEmpty);
      expect(result.nominal, 50000);
      expect(result.jenis, 'pengeluaran');
      expect(result.deskripsi, 'Makan siang');
    });

    test('persists the transaction in the database', () async {
      final transaction = createTransaction();

      final saved = await datasource.addTransaction(transaction);
      final retrieved = await datasource.getTransactionById(saved.id!);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, saved.id);
      expect(retrieved.nominal, saved.nominal);
    });
  });

  group('getTransactionById', () {
    test('returns the transaction when it exists', () async {
      final transaction = createTransaction(deskripsi: 'Test');
      final saved = await datasource.addTransaction(transaction);

      final result = await datasource.getTransactionById(saved.id!);

      expect(result, isNotNull);
      expect(result!.id, saved.id);
      expect(result.deskripsi, 'Test');
    });

    test('returns null when transaction does not exist', () async {
      final result = await datasource.getTransactionById('non-existent-id');

      expect(result, isNull);
    });
  });

  group('getTransactionsByDateRange', () {
    test('returns transactions within the date range', () async {
      final tx1 = createTransaction(tanggal: DateTime(2026, 5, 10));
      final tx2 = createTransaction(tanggal: DateTime(2026, 5, 15));
      final tx3 = createTransaction(tanggal: DateTime(2026, 5, 20));
      final txOutside = createTransaction(tanggal: DateTime(2026, 6, 1));

      await datasource.addTransaction(tx1);
      await datasource.addTransaction(tx2);
      await datasource.addTransaction(tx3);
      await datasource.addTransaction(txOutside);

      final results = await datasource.getTransactionsByDateRange(
        DateTime(2026, 5, 1),
        DateTime(2026, 5, 31),
      );

      expect(results, hasLength(3));
    });

    test('returns empty list when no transactions in range', () async {
      final tx = createTransaction(tanggal: DateTime(2026, 3, 1));
      await datasource.addTransaction(tx);

      final results = await datasource.getTransactionsByDateRange(
        DateTime(2026, 5, 1),
        DateTime(2026, 5, 31),
      );

      expect(results, isEmpty);
    });
  });

  group('updateTransaction', () {
    test('updates the transaction fields', () async {
      final transaction = createTransaction(
        nominal: 50000,
        deskripsi: 'Original',
      );
      final saved = await datasource.addTransaction(transaction);

      final toUpdate = saved.copyWith(nominal: 75000, deskripsi: 'Updated')
        ..isarId = saved.isarId;
      final updated = await datasource.updateTransaction(toUpdate);

      expect(updated.nominal, 75000);
      expect(updated.deskripsi, 'Updated');
    });

    test('sets syncStatus to false after update', () async {
      final transaction = createTransaction(syncStatus: true);
      final saved = await datasource.addTransaction(transaction);

      final toUpdate = saved.copyWith()..isarId = saved.isarId;
      final updated = await datasource.updateTransaction(toUpdate);

      expect(updated.syncStatus, isFalse);
    });

    test('persists the updated transaction', () async {
      final transaction = createTransaction(nominal: 100000);
      final saved = await datasource.addTransaction(transaction);

      final toUpdate = saved.copyWith(nominal: 200000)
        ..isarId = saved.isarId;
      await datasource.updateTransaction(toUpdate);

      final retrieved = await datasource.getTransactionById(saved.id!);
      expect(retrieved!.nominal, 200000);
    });
  });

  group('deleteTransaction', () {
    test('removes the transaction from the database', () async {
      final transaction = createTransaction();
      final saved = await datasource.addTransaction(transaction);

      await datasource.deleteTransaction(saved.id!);

      final retrieved = await datasource.getTransactionById(saved.id!);
      expect(retrieved, isNull);
    });

    test('does nothing when transaction does not exist', () async {
      // Should not throw
      await datasource.deleteTransaction('non-existent-id');

      final all = await datasource.getTransactions();
      expect(all, isEmpty);
    });
  });

  group('getUnsyncedTransactions', () {
    test('returns only transactions with syncStatus false', () async {
      final synced = createTransaction(syncStatus: true);
      final unsynced1 = createTransaction(syncStatus: false);
      final unsynced2 = createTransaction(syncStatus: false);

      await datasource.addTransaction(synced);
      await datasource.addTransaction(unsynced1);
      await datasource.addTransaction(unsynced2);

      final results = await datasource.getUnsyncedTransactions();

      expect(results, hasLength(2));
      for (final tx in results) {
        expect(tx.syncStatus, isFalse);
      }
    });

    test('returns empty list when all transactions are synced', () async {
      final synced = createTransaction(syncStatus: true);
      await datasource.addTransaction(synced);

      final results = await datasource.getUnsyncedTransactions();

      expect(results, isEmpty);
    });
  });
}
