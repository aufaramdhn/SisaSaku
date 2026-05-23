import 'dart:io';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisasaku/features/transaction/data/datasources/transaction_local_datasource.dart';
import 'package:sisasaku/features/transaction/data/models/transaction_model.dart';

/// Property-based tests for [TransactionLocalDatasource].
///
/// **Validates: Requirements 5.1**
///
/// Property 1: Transaction datasource CRUD round-trip
/// For any valid TransactionModel with non-null fields, adding it to the
/// TransactionLocalDatasource and then retrieving it by ID should return
/// a model with identical id, nominal, jenis, tanggal, idKategori, and
/// deskripsi values.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Isar isar;
  late TransactionLocalDatasource datasource;

  // Use a fixed seed for reproducibility across runs.
  const int randomSeed = 42;
  // Number of randomly generated transactions to test.
  const int sampleCount = 100;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final localAppData = Platform.environment['LOCALAPPDATA'];
    final libraryPath =
        '$localAppData\\Pub\\Cache\\hosted\\pub.dev\\isar_flutter_libs-3.1.0+1\\windows\\isar.dll';
    await Isar.initializeIsarCore(libraries: {Abi.current(): libraryPath});
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp(
      'sisasaku_tx_datasource_prop_',
    );
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

  /// Generates a random non-empty string of [length] alphanumeric characters.
  String randomString(Random rng, int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      List.generate(
        length,
        (_) => chars.codeUnitAt(rng.nextInt(chars.length)),
      ),
    );
  }

  /// Generates a random TransactionModel with all required fields non-null.
  TransactionModel generateTransaction(Random rng, int index) {
    // Vary nominal across a wide range, including small and large values.
    // Round to 2 decimals to avoid floating-point precision issues that are
    // unrelated to the round-trip property.
    final rawNominal = rng.nextDouble() * 10000000;
    final nominal = (rawNominal * 100).roundToDouble() / 100;

    // Alternate jenis to cover both pemasukan and pengeluaran.
    final jenis = rng.nextBool() ? 'pemasukan' : 'pengeluaran';

    // Random date within a ~10-year window centered on 2025.
    // Truncate to millisecond precision because Isar stores DateTimes at
    // millisecond resolution, while Dart's DateTime supports microseconds.
    final yearOffset = rng.nextInt(10) - 5;
    final month = rng.nextInt(12) + 1;
    final day = rng.nextInt(28) + 1;
    final hour = rng.nextInt(24);
    final minute = rng.nextInt(60);
    final second = rng.nextInt(60);
    final millis = rng.nextInt(1000);
    final tanggal = DateTime(
      2025 + yearOffset,
      month,
      day,
      hour,
      minute,
      second,
      millis,
    );

    final idKategori = 'kategori_${randomString(rng, 8)}';

    // Half of the time include a description, half of the time leave it null
    // — but the property statement specifies "non-null fields", so always
    // provide a non-null deskripsi.
    final deskripsi = 'desc_${index}_${randomString(rng, 12)}';

    return TransactionModel(
      nominal: nominal,
      jenis: jenis,
      tanggal: tanggal,
      idKategori: idKategori,
      deskripsi: deskripsi,
    );
  }

  group('Property 1: Transaction datasource CRUD round-trip', () {
    test(
      'add then getById returns a model with identical core fields '
      '(across $sampleCount random samples, seed=$randomSeed)',
      () async {
        final rng = Random(randomSeed);

        for (var i = 0; i < sampleCount; i++) {
          final original = generateTransaction(rng, i);

          final saved = await datasource.addTransaction(original);
          final retrieved = await datasource.getTransactionById(saved.id!);

          expect(
            retrieved,
            isNotNull,
            reason: 'Sample $i: retrieved transaction was null',
          );
          expect(
            retrieved!.id,
            original.id,
            reason: 'Sample $i: id mismatch',
          );
          expect(
            retrieved.nominal,
            original.nominal,
            reason: 'Sample $i: nominal mismatch',
          );
          expect(
            retrieved.jenis,
            original.jenis,
            reason: 'Sample $i: jenis mismatch',
          );
          expect(
            retrieved.tanggal,
            original.tanggal,
            reason: 'Sample $i: tanggal mismatch',
          );
          expect(
            retrieved.idKategori,
            original.idKategori,
            reason: 'Sample $i: idKategori mismatch',
          );
          expect(
            retrieved.deskripsi,
            original.deskripsi,
            reason: 'Sample $i: deskripsi mismatch',
          );
        }
      },
    );
  });
}
