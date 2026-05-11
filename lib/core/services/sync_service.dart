import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sisasaku/features/bill/data/models/bill_model.dart';
import 'package:sisasaku/features/category/data/models/category_model.dart';
import 'package:sisasaku/features/transaction/data/models/transaction_model.dart';

class SyncService {
  static const _lastSyncKey = 'last_sync_at';

  final Isar _isar;
  final SupabaseClient? _client;
  bool _isSyncing = false;

  SyncService({required Isar isar, required SupabaseClient? client})
    : _isar = isar,
      _client = client;

  Future<bool> shouldSync({
    Duration minInterval = const Duration(minutes: 5),
  }) async {
    if (_isSyncing) return false;
    final lastSync = await _getLastSyncAt();
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync) >= minInterval;
  }

  Future<void> syncAll() async {
    final client = _client;
    if (client == null || _isSyncing) return;
    final user = client.auth.currentUser;
    if (user == null) return;

    _isSyncing = true;
    try {
      final lastSyncAt = await _getLastSyncAt();
      await _pushCategories(user.id);
      await _pushTransactions(user.id);
      await _pushBills(user.id);

      await _pullCategories(user.id, lastSyncAt);
      await _pullTransactions(user.id, lastSyncAt);
      await _pullBills(user.id, lastSyncAt);

      await _setLastSyncAt(DateTime.now());
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushCategories(String userId) async {
    final unsynced = await _isar.categoryModels
        .filter()
        .syncStatusEqualTo(false)
        .findAll();
    if (unsynced.isEmpty) return;

    final rows = unsynced.map((c) => _categoryToRow(c, userId)).toList();
    await _client?.from('categories').upsert(rows, onConflict: 'id');

    await _isar.writeTxn(() async {
      for (final model in unsynced) {
        final updated = model.copyWith(
          syncStatus: true,
          updatedAt: DateTime.now(),
        );
        await _isar.categoryModels.put(updated..isarId = model.isarId);
      }
    });
  }

  Future<void> _pushTransactions(String userId) async {
    final unsynced = await _isar.transactionModels
        .filter()
        .syncStatusEqualTo(false)
        .findAll();
    if (unsynced.isEmpty) return;

    final rows = unsynced.map((t) => _transactionToRow(t, userId)).toList();
    await _client?.from('transactions').upsert(rows, onConflict: 'id');

    await _isar.writeTxn(() async {
      for (final model in unsynced) {
        final updated = model.copyWith(
          syncStatus: true,
          updatedAt: DateTime.now(),
        );
        await _isar.transactionModels.put(updated..isarId = model.isarId);
      }
    });
  }

  Future<void> _pushBills(String userId) async {
    final unsynced = await _isar.billModels
        .filter()
        .syncStatusEqualTo(false)
        .findAll();
    if (unsynced.isEmpty) return;

    final rows = unsynced.map((b) => _billToRow(b, userId)).toList();
    await _client?.from('bills').upsert(rows, onConflict: 'id');

    await _isar.writeTxn(() async {
      for (final model in unsynced) {
        final updated = model.copyWith(
          syncStatus: true,
          updatedAt: DateTime.now(),
        );
        await _isar.billModels.put(updated..isarId = model.isarId);
      }
    });
  }

  Future<void> _pullCategories(String userId, DateTime? lastSyncAt) async {
    final query = _client?.from('categories').select().eq('user_id', userId);
    if (query == null) return;
    final rows = lastSyncAt == null
        ? await query
        : await query.gt('updated_at', lastSyncAt.toIso8601String());

    await _isar.writeTxn(() async {
      for (final row in rows as List) {
        final model = _rowToCategory(row as Map<String, dynamic>);
        final existing = await _isar.categoryModels
            .where()
            .idEqualTo(model.id)
            .findFirst();
        await _isar.categoryModels.put(
          model.copyWith(syncStatus: true)..isarId = existing?.isarId,
        );
      }
    });
  }

  Future<void> _pullTransactions(String userId, DateTime? lastSyncAt) async {
    final query = _client?.from('transactions').select().eq('user_id', userId);
    if (query == null) return;
    final rows = lastSyncAt == null
        ? await query
        : await query.gt('updated_at', lastSyncAt.toIso8601String());

    await _isar.writeTxn(() async {
      for (final row in rows as List) {
        final model = _rowToTransaction(row as Map<String, dynamic>);
        final existing = await _isar.transactionModels
            .where()
            .idEqualTo(model.id)
            .findFirst();
        await _isar.transactionModels.put(
          model.copyWith(syncStatus: true)..isarId = existing?.isarId,
        );
      }
    });
  }

  Future<void> _pullBills(String userId, DateTime? lastSyncAt) async {
    final query = _client?.from('bills').select().eq('user_id', userId);
    if (query == null) return;
    final rows = lastSyncAt == null
        ? await query
        : await query.gt('updated_at', lastSyncAt.toIso8601String());

    await _isar.writeTxn(() async {
      for (final row in rows as List) {
        final model = _rowToBill(row as Map<String, dynamic>);
        final existing = await _isar.billModels
            .where()
            .idEqualTo(model.id)
            .findFirst();
        await _isar.billModels.put(
          model.copyWith(syncStatus: true)..isarId = existing?.isarId,
        );
      }
    });
  }

  Map<String, dynamic> _categoryToRow(CategoryModel model, String userId) {
    return {
      'id': model.id,
      'user_id': userId,
      'nama': model.nama,
      'ikon': model.ikon,
      'warna': model.warna,
      'created_at': model.createdAt?.toIso8601String(),
      'updated_at': model.updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> _transactionToRow(
    TransactionModel model,
    String userId,
  ) {
    return {
      'id': model.id,
      'user_id': userId,
      'nominal': model.nominal,
      'jenis': model.jenis,
      'tanggal': model.tanggal?.toIso8601String(),
      'id_kategori': model.idKategori,
      'deskripsi': model.deskripsi,
      'created_at': model.createdAt?.toIso8601String(),
      'updated_at': model.updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> _billToRow(BillModel model, String userId) {
    return {
      'id': model.id,
      'user_id': userId,
      'nama': model.nama,
      'nominal': model.nominal,
      'tanggal_jatuh_tempo': model.tanggalJatuhTempo?.toIso8601String(),
      'waktu_pengingat': model.waktuPengingat?.toIso8601String(),
      'status': model.status,
      'tanggal_pembayaran': model.tanggalPembayaran?.toIso8601String(),
      'deskripsi': model.deskripsi,
      'created_at': model.createdAt?.toIso8601String(),
      'updated_at': model.updatedAt?.toIso8601String(),
    };
  }

  CategoryModel _rowToCategory(Map<String, dynamic> row) {
    return CategoryModel(
      id: row['id'] as String?,
      nama: row['nama'] as String?,
      ikon: row['ikon'] as String?,
      warna: row['warna'] as String?,
      createdAt: _parseDate(row['created_at']),
      updatedAt: _parseDate(row['updated_at']),
      syncStatus: true,
    );
  }

  TransactionModel _rowToTransaction(Map<String, dynamic> row) {
    return TransactionModel(
      id: row['id'] as String?,
      nominal: (row['nominal'] as num?)?.toDouble(),
      jenis: row['jenis'] as String?,
      tanggal: _parseDate(row['tanggal']),
      idKategori: row['id_kategori'] as String?,
      deskripsi: row['deskripsi'] as String?,
      createdAt: _parseDate(row['created_at']),
      updatedAt: _parseDate(row['updated_at']),
      syncStatus: true,
    );
  }

  BillModel _rowToBill(Map<String, dynamic> row) {
    return BillModel(
      id: row['id'] as String?,
      nama: row['nama'] as String? ?? '',
      nominal: (row['nominal'] as num?)?.toDouble(),
      tanggalJatuhTempo: _parseDate(row['tanggal_jatuh_tempo']),
      waktuPengingat: _parseDate(row['waktu_pengingat']),
      status: row['status'] as String?,
      tanggalPembayaran: _parseDate(row['tanggal_pembayaran']),
      deskripsi: row['deskripsi'] as String?,
      createdAt: _parseDate(row['created_at']),
      updatedAt: _parseDate(row['updated_at']),
      syncStatus: true,
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Future<DateTime?> _getLastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastSyncKey);
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  Future<void> _setLastSyncAt(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, dateTime.toIso8601String());
  }
}
