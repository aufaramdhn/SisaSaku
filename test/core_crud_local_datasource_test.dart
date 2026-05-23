import 'dart:io';
import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisasaku/core/services/local_preferences_service.dart';
import 'package:sisasaku/features/bill/data/datasources/bill_local_datasource.dart';
import 'package:sisasaku/features/bill/data/models/bill_model.dart';
import 'package:sisasaku/features/budget/data/datasources/budget_local_datasource.dart';
import 'package:sisasaku/features/budget/data/models/budget_model.dart';
import 'package:sisasaku/features/debt/data/datasources/debt_local_datasource.dart';
import 'package:sisasaku/features/debt/data/models/debt_model.dart';
import 'package:sisasaku/features/splitbill/data/datasources/split_bill_local_datasource.dart';
import 'package:sisasaku/features/splitbill/data/models/split_bill_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Isar isar;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final localAppData = Platform.environment['LOCALAPPDATA'];
    final libraryPath =
        '$localAppData\\Pub\\Cache\\hosted\\pub.dev\\isar_flutter_libs-3.1.0+1\\windows\\isar.dll';
    await Isar.initializeIsarCore(libraries: {Abi.current(): libraryPath});
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sisasaku_core_crud_');
    isar = await Isar.open([
      BillModelSchema,
      BudgetModelSchema,
      DebtModelSchema,
      SplitBillModelSchema,
    ], directory: tempDir.path);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('budget datasource creates, updates, and deletes a budget', () async {
    final datasource = BudgetLocalDatasource(isar);
    final budget = BudgetModel(
      idKategori: 'food',
      namaKategori: 'Makan',
      limit: 500000,
      period: 'monthly',
      month: 5,
      year: 2026,
    );

    final saved = await datasource.addBudget(budget);
    expect(saved.id, isNotEmpty);
    expect(await datasource.getBudgetById(saved.id!), isNotNull);

    final updated = await datasource.updateBudget(
      saved.copyWith(limit: 750000),
    );
    expect(updated.limit, 750000);

    await datasource.deleteBudget(saved.id!);
    expect(await datasource.getBudgetById(saved.id!), isNull);
  });

  test('debt datasource creates and toggles settlement status', () async {
    final datasource = DebtLocalDatasource(isar);
    final debt = DebtModel(
      person: 'Andi',
      amount: 125000,
      date: DateTime(2026, 5, 14),
      notes: 'Makan siang',
      type: 'i_owe',
    );

    final saved = await datasource.addDebt(debt);
    expect(saved.isSettled, isFalse);

    final settled = await datasource.updateDebtSettlement(saved.id!, true);
    expect(settled.isSettled, isTrue);
    expect(settled.settledAt, isNotNull);
  });

  test(
    'split bill datasource stores participants and marks one as paid',
    () async {
      final datasource = SplitBillLocalDatasource(isar);
      final splitBill = SplitBillModel(
        title: 'Makan bareng',
        total: 300000,
        isEqualSplit: false,
        participantNames: ['Andi', 'Budi'],
        participantAmounts: [100000, 200000],
        paidParticipantNames: const [],
      );

      final saved = await datasource.addSplitBill(splitBill);
      expect(saved.participantNames, ['Andi', 'Budi']);

      final marked = await datasource.markParticipantPaid(
        saved.id!,
        'Andi',
        true,
      );
      expect(marked.paidParticipantNames, contains('Andi'));
      expect(marked.isSettled, isFalse);
    },
  );

  test(
    'bill datasource updates status without creating duplicate rows',
    () async {
      final datasource = BillLocalDatasource(isar);
      final bill = BillModel(
        nama: 'Kos',
        nominal: 1200000,
        tanggalJatuhTempo: DateTime(2026, 5, 21),
        waktuPengingat: DateTime(2026, 5, 18),
        status: 'akan_datang',
      );

      final saved = await datasource.addBill(bill);
      final updated = await datasource.updateBillStatus(saved.id!, 'lunas');

      expect(updated.status, 'lunas');
      expect(await datasource.getBills(), hasLength(1));
    },
  );

  test(
    'local preferences keeps guest and account profile scopes separate',
    () async {
      await LocalPreferencesService.saveProfile(
        scope: LocalPreferencesService.guestProfileScope,
        name: 'Guest Local',
        email: 'guest@example.com',
      );
      await LocalPreferencesService.saveProfile(
        scope: 'user-123',
        name: 'Akun Sync',
        email: 'sync@example.com',
      );

      expect(
        await LocalPreferencesService.getProfileName(
          scope: LocalPreferencesService.guestProfileScope,
        ),
        'Guest Local',
      );
      expect(
        await LocalPreferencesService.getProfileName(scope: 'user-123'),
        'Akun Sync',
      );
      expect(
        await LocalPreferencesService.getProfileEmail(scope: 'user-123'),
        'sync@example.com',
      );
    },
  );

  test(
    'local preferences can store and clear scoped profile avatar path',
    () async {
      await LocalPreferencesService.setProfileAvatarPath(
        scope: 'user-123',
        path: 'C:/tmp/avatar.png',
      );
      expect(
        await LocalPreferencesService.getProfileAvatarPath(scope: 'user-123'),
        'C:/tmp/avatar.png',
      );

      await LocalPreferencesService.setProfileAvatarPath(
        scope: 'user-123',
        path: null,
      );
      expect(
        await LocalPreferencesService.getProfileAvatarPath(scope: 'user-123'),
        isNull,
      );
    },
  );

  test('local preferences stores latest sync conflict per record', () async {
    await LocalPreferencesService.addSyncConflict(
      SyncConflictRecord(
        table: 'transactions',
        recordId: 'tx-1',
        reason: 'remote_newer_than_local_unsynced',
        detectedAt: DateTime(2026, 5, 15, 10),
      ),
    );
    await LocalPreferencesService.addSyncConflict(
      SyncConflictRecord(
        table: 'transactions',
        recordId: 'tx-1',
        reason: 'remote_newer_than_local_unsynced',
        detectedAt: DateTime(2026, 5, 15, 11),
      ),
    );

    final conflicts = await LocalPreferencesService.getSyncConflicts();
    expect(conflicts, hasLength(1));
    expect(conflicts.first.recordId, 'tx-1');
    expect(conflicts.first.detectedAt.hour, 11);

    await LocalPreferencesService.clearSyncConflict('transactions', 'tx-1');
    expect(await LocalPreferencesService.getSyncConflicts(), isEmpty);
  });
}
