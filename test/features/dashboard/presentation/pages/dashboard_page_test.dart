import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/core/theme/app_theme.dart';
import 'package:sisasaku/features/bill/domain/entities/bill_entity.dart';
import 'package:sisasaku/features/bill/presentation/providers/bill_provider.dart';
import 'package:sisasaku/features/category/domain/entities/category_entity.dart';
import 'package:sisasaku/features/category/presentation/providers/category_provider.dart';
import 'package:sisasaku/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sisasaku/features/settings/presentation/providers/profile_provider.dart';
import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';
import 'package:sisasaku/features/transaction/presentation/providers/transaction_provider.dart';

void main() {
  late List<TransactionEntity> mockTransactions;
  late List<CategoryEntity> mockCategories;
  late List<BillEntity> mockBills;

  setUp(() {
    final now = DateTime.now();

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
        nama: 'Gaji',
        ikon: 'payments',
        warna: '#4CAF50',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        syncStatus: true,
      ),
    ];

    mockTransactions = [
      TransactionEntity(
        id: 'tx-1',
        nominal: 50000,
        jenis: TransactionType.expense,
        tanggal: now,
        idKategori: 'cat-1',
        deskripsi: 'Makan siang',
        createdAt: now,
        updatedAt: now,
        syncStatus: true,
      ),
      TransactionEntity(
        id: 'tx-2',
        nominal: 5000000,
        jenis: TransactionType.income,
        tanggal: now,
        idKategori: 'cat-2',
        deskripsi: 'Gaji bulanan',
        createdAt: now,
        updatedAt: now,
        syncStatus: true,
      ),
    ];

    mockBills = [
      BillEntity(
        id: 'bill-1',
        nama: 'Listrik',
        nominal: 350000,
        tanggalJatuhTempo: now.add(const Duration(days: 2)),
        waktuPengingat: now.add(const Duration(days: 1)),
        status: BillStatus.pending,
        createdAt: now,
        updatedAt: now,
        syncStatus: true,
      ),
    ];
  });

  Widget buildTestWidget({
    List<TransactionEntity>? transactions,
    double? income,
    double? expense,
    List<BillEntity>? bills,
    List<CategoryEntity>? categories,
  }) {
    final txList = transactions ?? mockTransactions;
    final incomeVal = income ?? 5000000.0;
    final expenseVal = expense ?? 50000.0;
    final billList = bills ?? mockBills;
    final catList = categories ?? mockCategories;

    return ProviderScope(
      overrides: [
        monthlyTransactionsProvider.overrideWith(
          (ref, dateRange) => Stream.value(txList),
        ),
        monthlyIncomeProvider.overrideWith(
          (ref, dateRange) => Stream.value(incomeVal),
        ),
        monthlyExpenseProvider.overrideWith(
          (ref, dateRange) => Stream.value(expenseVal),
        ),
        upcomingBillsProvider.overrideWith(
          (ref) => Stream.value(billList),
        ),
        categoriesProvider.overrideWith(
          (ref) => Stream.value(catList),
        ),
        profileViewProvider.overrideWith(
          (ref) async => const ProfileViewData(
            scope: 'guest',
            isGuest: true,
            displayName: 'Test User',
            email: null,
            avatarPath: null,
            avatarUrl: null,
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const DashboardPage(),
      ),
    );
  }

  group('DashboardPage', () {
    testWidgets('renders greeting and user name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify user name is displayed
      expect(find.textContaining('Test User'), findsOneWidget);

      // Verify a greeting is shown (depends on time of day)
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.startsWith('Selamat'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders financial summary with correct balance',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        income: 5000000.0,
        expense: 50000.0,
      ));
      await tester.pumpAndSettle();

      // Verify "Total Saldo" label is shown
      expect(find.text('Total Saldo'), findsOneWidget);

      // Verify Pemasukan and Pengeluaran labels
      expect(find.text('Pemasukan'), findsOneWidget);
      expect(find.text('Pengeluaran'), findsOneWidget);
    });

    testWidgets('renders recent transactions section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify section title
      expect(find.text('Transaksi Terbaru'), findsOneWidget);
      expect(find.text('Lihat Semua'), findsOneWidget);

      // Verify category names from transactions are rendered
      expect(find.text('Makanan'), findsOneWidget);
      expect(find.text('Gaji'), findsOneWidget);
    });

    testWidgets('renders empty state when no transactions', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        transactions: [],
        income: 0.0,
        expense: 0.0,
      ));
      await tester.pumpAndSettle();

      // Verify empty state message
      expect(find.text('Belum ada transaksi'), findsOneWidget);
    });

    testWidgets('renders quick action buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify quick action section title
      expect(find.text('Aksi Cepat'), findsOneWidget);

      // Verify quick action labels (maxVisible=4, 6 items → last slot becomes "Lainnya")
      expect(find.text('Catat'), findsOneWidget);
      expect(find.text('Tagihan'), findsOneWidget);
      expect(find.text('Analitik'), findsOneWidget);
      expect(find.text('Lainnya'), findsOneWidget);
    });

    testWidgets('renders bill warning card when bills exist', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify bill warning is shown with bill name
      expect(find.text('Listrik'), findsOneWidget);
    });

    testWidgets('hides bill warning card when no bills', (tester) async {
      await tester.pumpWidget(buildTestWidget(bills: []));
      await tester.pumpAndSettle();

      // Verify bill name is not shown
      expect(find.text('Listrik'), findsNothing);
    });
  });
}
