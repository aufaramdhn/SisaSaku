import 'dart:math';
import 'package:flutter/foundation.dart';

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/features/bill/data/models/bill_model.dart';
import 'package:sisasaku/features/category/data/models/category_model.dart';
import 'package:sisasaku/features/transaction/data/models/transaction_model.dart';

/// Service untuk generate data dummy dan clear data (dev only)
class DummyDataService {
  static final _random = Random();
  static const _uuid = Uuid();

  static final List<Map<String, String>> _categoryPresets = const [
    {'nama': 'Makanan', 'ikon': 'restaurant', 'warna': '#1D9E75'},
    {'nama': 'Transportasi', 'ikon': 'directions_car', 'warna': '#1E88E5'},
    {'nama': 'Gaji', 'ikon': 'payments', 'warna': '#43A047'},
    {'nama': 'Belanja', 'ikon': 'shopping_bag', 'warna': '#FB8C00'},
    {'nama': 'Hiburan', 'ikon': 'sports_esports', 'warna': '#8E24AA'},
    {'nama': 'Kesehatan', 'ikon': 'favorite', 'warna': '#E53935'},
    {'nama': 'Pendidikan', 'ikon': 'school', 'warna': '#3949AB'},
    {'nama': 'Investasi', 'ikon': 'trending_up', 'warna': '#00ACC1'},
  ];

  static final List<String> _expenseDescriptions = const [
    'Makan siang',
    'Bensin',
    'Parkir',
    'Kopi',
    'Snack',
    'Taksi online',
    'Makan malam',
    'Belanja bulanan',
    'Obat',
    'Pulsa',
    'Nonton bioskop',
    'Beli buku',
    'Bayar tol',
    'Servis motor',
    'Beli pakaian',
    'Makan di restoran',
    'Bayar listrik',
    'Bayar air',
    'Langganan streaming',
    'Beli alat tulis',
  ];

  static final List<String> _incomeDescriptions = const [
    'Gaji bulanan',
    'Bonus kerja',
    'THR',
    'Refund',
    'Hasil jualan',
    'Dividen',
    'Cashback',
    'Hadiah',
    'Project freelance',
    'Sewa kos',
  ];

  static final List<String> _billNames = const [
    'Netflix',
    'Spotify',
    'Listrik PLN',
    'Internet WiFi',
    'Kos Bulanan',
    'Air PDAM',
    'Asuransi',
    'Langganan Gym',
    'Cicilan Motor',
    'Pajak Kendaraan',
  ];

  /// Generate sample data untuk development/testing
  static Future<void> generateSampleData(Isar isar) async {
    if (kReleaseMode) {
      throw StateError('DummyDataService is disabled in release builds.');
    }
    // 1. Generate 8 categories
    final categories = _categoryPresets.map((preset) {
      return CategoryModel(
        id: _uuid.v4(),
        nama: preset['nama']!,
        ikon: preset['ikon']!,
        warna: preset['warna']!,
        syncStatus: false,
      );
    }).toList();

    await isar.writeTxn(() async {
      for (final category in categories) {
        await isar.categoryModels.put(category);
      }
    });

    // 2. Generate 30 transactions with random dates in last 30 days
    final expenseCategories = categories
        .where(
          (c) => ![
            'gaji',
            'bonus',
            'investasi',
            'hadiah',
            'penjualan',
          ].contains(c.nama?.toLowerCase()),
        )
        .toList();
    final incomeCategories = categories
        .where(
          (c) => [
            'gaji',
            'bonus',
            'investasi',
            'hadiah',
            'penjualan',
          ].contains(c.nama?.toLowerCase()),
        )
        .toList();

    final now = DateTime.now();
    final transactions = <TransactionModel>[];

    for (int i = 0; i < 30; i++) {
      final isExpense = _random.nextBool();
      final daysAgo = _random.nextInt(30);
      final tanggal = now.subtract(Duration(days: daysAgo));

      final double nominal;
      final String idKategori;
      final String deskripsi;

      if (isExpense) {
        nominal = (50000 + _random.nextInt(450001)).toDouble(); // 50k - 500k
        idKategori =
            expenseCategories[_random.nextInt(expenseCategories.length)].id!;
        deskripsi =
            _expenseDescriptions[_random.nextInt(_expenseDescriptions.length)];
      } else {
        nominal = (1000000 + _random.nextInt(4000001)).toDouble(); // 1M - 5M
        idKategori =
            incomeCategories[_random.nextInt(incomeCategories.length)].id!;
        deskripsi =
            _incomeDescriptions[_random.nextInt(_incomeDescriptions.length)];
      }

      transactions.add(
        TransactionModel(
          id: _uuid.v4(),
          nominal: nominal,
          jenis: isExpense
              ? TransactionType.expense.label
              : TransactionType.income.label,
          tanggal: tanggal,
          idKategori: idKategori,
          deskripsi: deskripsi,
          syncStatus: false,
        ),
      );
    }

    await isar.writeTxn(() async {
      for (final transaction in transactions) {
        await isar.transactionModels.put(transaction);
      }
    });

    // 3. Generate 5 bills with due dates spread across current month
    final currentMonth = now.month;
    final currentYear = now.year;
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;

    final bills = <BillModel>[];
    for (int i = 0; i < 5; i++) {
      final day = 5 + _random.nextInt(daysInMonth - 4); // day 5 to end of month
      final tanggalJatuhTempo = DateTime(currentYear, currentMonth, day);
      final waktuPengingat = DateTime(currentYear, currentMonth, day - 1, 8, 0);

      final status =
          tanggalJatuhTempo.isBefore(DateTime(now.year, now.month, now.day))
          ? BillStatus.overdue.label
          : (tanggalJatuhTempo
                        .difference(DateTime(now.year, now.month, now.day))
                        .inDays <=
                    3
                ? BillStatus.pending.label
                : BillStatus.upcoming.label);

      bills.add(
        BillModel(
          id: _uuid.v4(),
          nama: _billNames[_random.nextInt(_billNames.length)],
          nominal: (100000 + _random.nextInt(900001)).toDouble(), // 100k - 1M
          tanggalJatuhTempo: tanggalJatuhTempo,
          waktuPengingat: waktuPengingat,
          status: status,
          syncStatus: false,
        ),
      );
    }

    await isar.writeTxn(() async {
      for (final bill in bills) {
        await isar.billModels.put(bill);
      }
    });
  }

  /// Clear all data dari ketiga collections
  static Future<void> clearAllData(Isar isar) async {
    if (kReleaseMode) {
      throw StateError('DummyDataService is disabled in release builds.');
    }
    await isar.writeTxn(() async {
      await isar.categoryModels.clear();
      await isar.transactionModels.clear();
      await isar.billModels.clear();
    });
  }
}
