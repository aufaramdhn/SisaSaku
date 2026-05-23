import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/features/category/domain/entities/category_entity.dart';
import 'package:sisasaku/features/category/presentation/providers/category_provider.dart';
import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';
import 'package:sisasaku/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:sisasaku/features/transaction/presentation/pages/add_transaction_page.dart';
import 'package:sisasaku/features/transaction/presentation/providers/transaction_provider.dart';

/// A fake TransactionRepository for testing
class FakeTransactionRepository implements TransactionRepository {
  final List<TransactionEntity> addedTransactions = [];

  @override
  Future<TransactionEntity> addTransaction(TransactionEntity transaction) async {
    addedTransactions.add(transaction);
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {}

  @override
  Future<List<TransactionEntity>> getMonthlyTransactions(int month, int year) async => [];

  @override
  Future<TransactionEntity?> getTransactionById(String id) async => null;

  @override
  Future<List<TransactionEntity>> getTransactions() async => [];

  @override
  Future<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async => [];

  @override
  Future<List<TransactionEntity>> getUnsyncedTransactions() async => [];

  @override
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction) async => transaction;

  @override
  Stream<List<TransactionEntity>> watchTransactions() => Stream.value([]);

  @override
  Stream<List<TransactionEntity>> watchTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) => Stream.value([]);
}

void main() {
  late FakeTransactionRepository fakeRepository;
  late List<CategoryEntity> mockCategories;

  setUp(() {
    fakeRepository = FakeTransactionRepository();
    mockCategories = [
      CategoryEntity(
        id: 'cat-1',
        nama: 'Makanan',
        ikon: 'restaurant',
        warna: '#FF5722',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        syncStatus: true,
      ),
      CategoryEntity(
        id: 'cat-2',
        nama: 'Transport',
        ikon: 'directions_car',
        warna: '#2196F3',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        syncStatus: true,
      ),
    ];
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        categoriesProvider.overrideWith(
          (ref) => Stream.value(mockCategories),
        ),
        transactionRepositoryProvider.overrideWith(
          (ref) async => fakeRepository,
        ),
      ],
      child: const MaterialApp(
        home: AddTransactionPage(),
      ),
    );
  }

  group('AddTransactionPage', () {
    testWidgets('renders page title and form fields', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify page title
      expect(find.text('Catat Transaksi'), findsOneWidget);

      // Verify toggle buttons
      expect(find.text('Pengeluaran'), findsOneWidget);
      expect(find.text('Pemasukan'), findsOneWidget);

      // Verify nominal field label
      expect(find.text('Nominal'), findsOneWidget);
      expect(find.text('Rp'), findsOneWidget);

      // Verify submit button
      expect(find.text('Simpan Transaksi'), findsOneWidget);
    });

    testWidgets('shows error dialog when nominal is empty and submit is tapped',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap submit without entering nominal
      await tester.tap(find.text('Simpan Transaksi'));
      await tester.pumpAndSettle();

      // Verify error dialog appears with validation message
      expect(find.text('Nominal belum valid'), findsOneWidget);
      expect(find.text('Nominal harus lebih dari 0.'), findsOneWidget);
    });

    testWidgets('shows error dialog when nominal is filled but no category selected',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Enter a nominal value
      final nominalField = find.byType(TextField).first;
      await tester.enterText(nominalField, '50000');
      await tester.pumpAndSettle();

      // Tap submit without selecting a category
      await tester.tap(find.text('Simpan Transaksi'));
      await tester.pumpAndSettle();

      // Verify category error dialog appears
      expect(find.text('Kategori belum dipilih'), findsOneWidget);
      expect(find.text('Silakan pilih kategori terlebih dahulu.'), findsOneWidget);
    });

    testWidgets('renders categories from provider', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify categories are rendered
      expect(find.text('Makanan'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('successful submission when form is valid', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Enter a nominal value
      final nominalField = find.byType(TextField).first;
      await tester.enterText(nominalField, '50000');
      await tester.pumpAndSettle();

      // Select a category
      await tester.tap(find.text('Makanan'));
      await tester.pumpAndSettle();

      // Tap submit
      await tester.tap(find.text('Simpan Transaksi'));
      // Use pump() to allow the async operation to complete without waiting
      // for animations (CircularProgressIndicator) to settle
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify success dialog appears
      expect(find.text('Transaksi berhasil disimpan'), findsOneWidget);
      expect(find.text('Data transaksi sudah masuk ke daftar.'), findsOneWidget);

      // Verify the transaction was added to the fake repository
      expect(fakeRepository.addedTransactions.length, 1);
      expect(fakeRepository.addedTransactions.first.nominal, 50000.0);
      expect(fakeRepository.addedTransactions.first.idKategori, 'cat-1');
    });

    testWidgets('can toggle between expense and income', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap on Pemasukan toggle
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      // Fill form and submit
      final nominalField = find.byType(TextField).first;
      await tester.enterText(nominalField, '100000');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Transport'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan Transaksi'));
      // Use pump() to allow the async operation to complete without waiting
      // for animations (CircularProgressIndicator) to settle
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify success and income type
      expect(find.text('Transaksi berhasil disimpan'), findsOneWidget);
      expect(fakeRepository.addedTransactions.length, 1);
      expect(fakeRepository.addedTransactions.first.idKategori, 'cat-2');
    });
  });
}
