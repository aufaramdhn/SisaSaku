import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/core/errors/exceptions.dart';
import 'package:sisasaku/features/transaction/data/datasources/transaction_local_datasource.dart';
import 'package:sisasaku/features/transaction/data/models/transaction_model.dart';
import 'package:sisasaku/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';

/// Fake datasource that stores transactions in memory for testing.
/// Uses `implements` to avoid needing a real Isar instance.
class FakeTransactionLocalDatasource implements TransactionLocalDatasource {
  final List<TransactionModel> _store = [];
  bool shouldThrow = false;
  String throwMessage = 'Fake database error';

  @override
  Isar get isar => throw UnimplementedError('Isar not used in fake');

  void _checkThrow() {
    if (shouldThrow) {
      throw DatabaseException(message: throwMessage);
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    _checkThrow();
    return List.from(_store);
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    _checkThrow();
    try {
      return _store.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _checkThrow();
    return _store
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
    _checkThrow();
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
    return getTransactionsByDateRange(startDate, endDate);
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    _checkThrow();
    _store.add(transaction);
    return transaction;
  }

  @override
  Future<TransactionModel> updateTransaction(
    TransactionModel transaction,
  ) async {
    _checkThrow();
    _store.removeWhere((t) => t.id == transaction.id);
    _store.add(transaction);
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _checkThrow();
    _store.removeWhere((t) => t.id == id);
  }

  @override
  Future<List<TransactionModel>> getUnsyncedTransactions() async {
    _checkThrow();
    return _store.where((t) => t.syncStatus == false).toList();
  }

  @override
  Stream<List<TransactionModel>> watchTransactions() {
    if (shouldThrow) {
      throw DatabaseException(message: throwMessage);
    }
    return Stream.value(List.from(_store));
  }

  @override
  Stream<List<TransactionModel>> watchTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (shouldThrow) {
      throw DatabaseException(message: throwMessage);
    }
    final filtered =
        _store
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
    _checkThrow();
    final index = _store.indexWhere((t) => t.id == id);
    if (index != -1) {
      _store[index] = _store[index].copyWith(syncStatus: true);
    }
  }
}

void main() {
  late FakeTransactionLocalDatasource fakeDatasource;
  late TransactionRepositoryImpl repository;

  setUp(() {
    fakeDatasource = FakeTransactionLocalDatasource();
    repository = TransactionRepositoryImpl(fakeDatasource);
  });

  group('Model to Entity mapping', () {
    test('preserves all fields when converting model to entity', () async {
      final now = DateTime(2026, 5, 15, 10, 30);
      final model = TransactionModel(
        id: 'test-id-123',
        nominal: 150000.0,
        jenis: 'masuk',
        tanggal: now,
        idKategori: 'cat-food',
        deskripsi: 'Gaji bulanan',
        createdAt: now,
        updatedAt: now,
        syncStatus: true,
      );

      await fakeDatasource.addTransaction(model);
      final entity = await repository.getTransactionById('test-id-123');

      expect(entity, isNotNull);
      expect(entity!.id, 'test-id-123');
      expect(entity.nominal, 150000.0);
      expect(entity.jenis, TransactionType.income);
      expect(entity.tanggal, now);
      expect(entity.idKategori, 'cat-food');
      expect(entity.deskripsi, 'Gaji bulanan');
      expect(entity.createdAt, now);
      expect(entity.updatedAt, now);
      expect(entity.syncStatus, true);
    });

    test('maps expense jenis correctly', () async {
      final model = TransactionModel(
        id: 'expense-1',
        nominal: 50000.0,
        jenis: 'keluar',
        tanggal: DateTime(2026, 5, 10),
        idKategori: 'cat-transport',
        deskripsi: null,
        syncStatus: false,
      );

      await fakeDatasource.addTransaction(model);
      final entity = await repository.getTransactionById('expense-1');

      expect(entity, isNotNull);
      expect(entity!.jenis, TransactionType.expense);
      expect(entity.deskripsi, isNull);
      expect(entity.syncStatus, false);
    });

    test('handles null deskripsi field', () async {
      final model = TransactionModel(
        id: 'no-desc',
        nominal: 25000.0,
        jenis: 'masuk',
        tanggal: DateTime(2026, 3, 1),
        idKategori: 'cat-misc',
        deskripsi: null,
        syncStatus: false,
      );

      await fakeDatasource.addTransaction(model);
      final entity = await repository.getTransactionById('no-desc');

      expect(entity, isNotNull);
      expect(entity!.deskripsi, isNull);
    });
  });

  group('Entity to Model mapping', () {
    test('preserves all fields when converting entity to model via add',
        () async {
      final now = DateTime(2026, 6, 1, 8, 0);
      final entity = TransactionEntity(
        id: 'entity-id-456',
        nominal: 200000.0,
        jenis: TransactionType.income,
        tanggal: now,
        idKategori: 'cat-salary',
        deskripsi: 'Bonus',
        createdAt: now,
        updatedAt: now,
        syncStatus: true,
      );

      final result = await repository.addTransaction(entity);

      // Verify the returned entity preserves all fields
      expect(result.id, 'entity-id-456');
      expect(result.nominal, 200000.0);
      expect(result.jenis, TransactionType.income);
      expect(result.tanggal, now);
      expect(result.idKategori, 'cat-salary');
      expect(result.deskripsi, 'Bonus');
      expect(result.createdAt, now);
      expect(result.updatedAt, now);
      expect(result.syncStatus, true);

      // Verify the model stored in datasource has correct values
      final storedModel =
          await fakeDatasource.getTransactionById('entity-id-456');
      expect(storedModel, isNotNull);
      expect(storedModel!.id, 'entity-id-456');
      expect(storedModel.nominal, 200000.0);
      expect(storedModel.jenis, 'masuk');
      expect(storedModel.tanggal, now);
      expect(storedModel.idKategori, 'cat-salary');
      expect(storedModel.deskripsi, 'Bonus');
      expect(storedModel.syncStatus, true);
    });

    test('maps expense entity to model with correct jenis label', () async {
      final entity = TransactionEntity(
        id: 'expense-entity',
        nominal: 75000.0,
        jenis: TransactionType.expense,
        tanggal: DateTime(2026, 4, 20),
        idKategori: 'cat-food',
        deskripsi: 'Makan siang',
        createdAt: DateTime(2026, 4, 20),
        updatedAt: DateTime(2026, 4, 20),
        syncStatus: false,
      );

      await repository.addTransaction(entity);

      final storedModel =
          await fakeDatasource.getTransactionById('expense-entity');
      expect(storedModel, isNotNull);
      expect(storedModel!.jenis, 'keluar');
    });
  });

  group('Round-trip mapping (entity → model → entity)', () {
    test('entity survives round-trip through repository add and get',
        () async {
      final now = DateTime(2026, 7, 10, 14, 30);
      final original = TransactionEntity(
        id: 'roundtrip-1',
        nominal: 350000.0,
        jenis: TransactionType.expense,
        tanggal: now,
        idKategori: 'cat-entertainment',
        deskripsi: 'Nonton bioskop',
        createdAt: now,
        updatedAt: now,
        syncStatus: false,
      );

      await repository.addTransaction(original);
      final retrieved = await repository.getTransactionById('roundtrip-1');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, original.id);
      expect(retrieved.nominal, original.nominal);
      expect(retrieved.jenis, original.jenis);
      expect(retrieved.tanggal, original.tanggal);
      expect(retrieved.idKategori, original.idKategori);
      expect(retrieved.deskripsi, original.deskripsi);
      expect(retrieved.createdAt, original.createdAt);
      expect(retrieved.updatedAt, original.updatedAt);
      expect(retrieved.syncStatus, original.syncStatus);
    });
  });

  group('Error propagation', () {
    test('getTransactions propagates DatabaseException', () async {
      fakeDatasource.shouldThrow = true;
      fakeDatasource.throwMessage = 'Gagal mengambil transaksi';

      expect(
        () => repository.getTransactions(),
        throwsA(
          isA<DatabaseException>().having(
            (e) => e.message,
            'message',
            'Gagal mengambil transaksi',
          ),
        ),
      );
    });

    test('getTransactionById propagates DatabaseException', () async {
      fakeDatasource.shouldThrow = true;

      expect(
        () => repository.getTransactionById('any-id'),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('addTransaction propagates DatabaseException', () async {
      fakeDatasource.shouldThrow = true;

      final entity = TransactionEntity(
        id: 'fail-add',
        nominal: 100000.0,
        jenis: TransactionType.income,
        tanggal: DateTime(2026, 1, 1),
        idKategori: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        syncStatus: false,
      );

      expect(
        () => repository.addTransaction(entity),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('updateTransaction propagates DatabaseException', () async {
      fakeDatasource.shouldThrow = true;

      final entity = TransactionEntity(
        id: 'fail-update',
        nominal: 100000.0,
        jenis: TransactionType.expense,
        tanggal: DateTime(2026, 2, 1),
        idKategori: 'cat-2',
        createdAt: DateTime(2026, 2, 1),
        updatedAt: DateTime(2026, 2, 1),
        syncStatus: false,
      );

      expect(
        () => repository.updateTransaction(entity),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('deleteTransaction propagates DatabaseException', () async {
      fakeDatasource.shouldThrow = true;

      expect(
        () => repository.deleteTransaction('some-id'),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('getUnsyncedTransactions propagates DatabaseException', () async {
      fakeDatasource.shouldThrow = true;

      expect(
        () => repository.getUnsyncedTransactions(),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('getTransactionsByDateRange propagates DatabaseException', () async {
      fakeDatasource.shouldThrow = true;

      expect(
        () => repository.getTransactionsByDateRange(
          DateTime(2026, 1, 1),
          DateTime(2026, 12, 31),
        ),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('watchTransactions propagates DatabaseException', () {
      fakeDatasource.shouldThrow = true;

      expect(
        () => repository.watchTransactions(),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('List operations', () {
    test('getTransactions returns mapped entities for all stored models',
        () async {
      final models = [
        TransactionModel(
          id: 'tx-1',
          nominal: 100000.0,
          jenis: 'masuk',
          tanggal: DateTime(2026, 5, 1),
          idKategori: 'cat-1',
          syncStatus: true,
        ),
        TransactionModel(
          id: 'tx-2',
          nominal: 50000.0,
          jenis: 'keluar',
          tanggal: DateTime(2026, 5, 2),
          idKategori: 'cat-2',
          syncStatus: false,
        ),
      ];

      for (final m in models) {
        await fakeDatasource.addTransaction(m);
      }

      final entities = await repository.getTransactions();
      expect(entities, hasLength(2));
      expect(entities[0].id, 'tx-1');
      expect(entities[0].jenis, TransactionType.income);
      expect(entities[1].id, 'tx-2');
      expect(entities[1].jenis, TransactionType.expense);
    });

    test('getUnsyncedTransactions only returns unsynced entities', () async {
      await fakeDatasource.addTransaction(TransactionModel(
        id: 'synced',
        nominal: 100000.0,
        jenis: 'masuk',
        tanggal: DateTime(2026, 5, 1),
        idKategori: 'cat-1',
        syncStatus: true,
      ));
      await fakeDatasource.addTransaction(TransactionModel(
        id: 'unsynced',
        nominal: 50000.0,
        jenis: 'keluar',
        tanggal: DateTime(2026, 5, 2),
        idKategori: 'cat-2',
        syncStatus: false,
      ));

      final unsynced = await repository.getUnsyncedTransactions();
      expect(unsynced, hasLength(1));
      expect(unsynced[0].id, 'unsynced');
      expect(unsynced[0].syncStatus, false);
    });

    test('getTransactionById returns null for non-existent id', () async {
      final result = await repository.getTransactionById('non-existent');
      expect(result, isNull);
    });
  });
}
