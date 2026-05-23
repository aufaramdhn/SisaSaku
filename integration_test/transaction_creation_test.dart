import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/core/providers/isar_provider.dart';
import 'package:sisasaku/features/category/data/datasources/category_local_datasource.dart';
import 'package:sisasaku/features/category/data/models/category_model.dart';
import 'package:sisasaku/features/transaction/data/datasources/transaction_local_datasource.dart';
import 'package:sisasaku/features/transaction/data/models/transaction_model.dart';
import 'package:sisasaku/features/transaction/presentation/pages/add_transaction_page.dart';

/// Integration test for the transaction creation flow.
///
/// This test exercises the full end-to-end path:
///   1. The user fills in the AddTransactionPage form (nominal + category)
///   2. The form submission calls the real TransactionRepository
///   3. The repository persists the transaction via the real Isar datasource
///   4. The test reads the transaction back directly from the datasource and
///      asserts that all field values were persisted correctly.
///
/// Unlike the unit-style widget test in
/// `test/features/transaction/presentation/pages/add_transaction_page_test.dart`,
/// this test uses a real Isar instance backed by a temporary directory rather
/// than a fake repository, which validates the actual persistence layer.
///
/// _Validates: Requirements 10.4_
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Isar isar;

  setUpAll(() async {
    // The integration test runs as a Dart VM test on the host platform when
    // invoked via `flutter test integration_test/...`. On Windows we need to
    // initialize the Isar core library manually because there is no Flutter
    // engine to load `isar_flutter_libs` via plugin registration.
    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData != null) {
      final libraryPath =
          '$localAppData\\Pub\\Cache\\hosted\\pub.dev\\isar_flutter_libs-3.1.0+1\\windows\\isar.dll';
      if (File(libraryPath).existsSync()) {
        await Isar.initializeIsarCore(
          libraries: {Abi.current(): libraryPath},
        );
      }
    }
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('sisasaku_tx_integration_');
    isar = await Isar.open(
      [TransactionModelSchema, CategoryModelSchema],
      directory: tempDir.path,
    );

    // Seed a category so the AddTransactionPage form can pick one.
    final categoryDatasource = CategoryLocalDatasource(isar);
    await categoryDatasource.addCategory(
      CategoryModel(
        id: 'cat-makanan',
        nama: 'Makanan',
        ikon: 'restaurant',
        warna: '#FF5722',
      ),
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        // Wire the real Isar instance into the providers so the page uses
        // production code paths (categoriesProvider, transactionRepositoryProvider).
        isarProvider.overrideWithValue(isar),
      ],
      child: const MaterialApp(home: AddTransactionPage()),
    );
  }

  testWidgets(
    'persists a transaction end-to-end through the AddTransactionPage form',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // The seeded category should appear in the UI.
      expect(find.text('Makanan'), findsOneWidget);

      // Enter nominal amount.
      final nominalField = find.byType(TextField).first;
      await tester.enterText(nominalField, '125000');
      await tester.pumpAndSettle();

      // Pick the seeded category.
      await tester.tap(find.text('Makanan'));
      await tester.pumpAndSettle();

      // Submit the form. We avoid pumpAndSettle because the success dialog
      // contains a CircularProgressIndicator-like animation in some flows;
      // pump twice to allow the async addTransaction call to complete.
      await tester.tap(find.text('Simpan Transaksi'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // The success dialog confirms the form considered the save successful.
      expect(find.text('Transaksi berhasil disimpan'), findsOneWidget);

      // Now verify persistence by reading directly from the datasource.
      final datasource = TransactionLocalDatasource(isar);
      final stored = await datasource.getTransactions();

      expect(stored, hasLength(1));
      final tx = stored.first;
      expect(tx.nominal, 125000);
      expect(tx.jenis, TransactionType.expense.label);
      expect(tx.idKategori, 'cat-makanan');
      expect(tx.id, isNotNull);
      expect(tx.id, isNotEmpty);
      // syncStatus is false on creation because the transaction has not yet
      // been pushed to the cloud.
      expect(tx.syncStatus, isFalse);
    },
  );

  testWidgets(
    'persists an income transaction when the income toggle is selected',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Switch to income mode.
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      // Enter nominal amount.
      final nominalField = find.byType(TextField).first;
      await tester.enterText(nominalField, '500000');
      await tester.pumpAndSettle();

      // Pick the seeded category.
      await tester.tap(find.text('Makanan'));
      await tester.pumpAndSettle();

      // Submit.
      await tester.tap(find.text('Simpan Transaksi'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Transaksi berhasil disimpan'), findsOneWidget);

      // Verify the persisted transaction has the income type label.
      final datasource = TransactionLocalDatasource(isar);
      final stored = await datasource.getTransactions();
      expect(stored, hasLength(1));
      expect(stored.first.nominal, 500000);
      expect(stored.first.jenis, TransactionType.income.label);
    },
  );
}
