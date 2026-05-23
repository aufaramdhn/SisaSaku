import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sisasaku/core/services/local_preferences_service.dart';
import 'package:sisasaku/features/bill/data/models/bill_model.dart';
import 'package:sisasaku/features/budget/data/models/budget_model.dart';
import 'package:sisasaku/features/category/data/models/category_model.dart';
import 'package:sisasaku/features/debt/data/models/debt_model.dart';
import 'package:sisasaku/features/splitbill/data/models/split_bill_model.dart';
import 'package:sisasaku/features/transaction/data/models/transaction_model.dart';

class SyncStatusSnapshot {
  final bool isSyncing;
  final DateTime? lastSyncAt;
  final String? lastError;
  final int pendingChangeCount;
  final int conflictCount;
  final DateTime? lastConflictAt;

  const SyncStatusSnapshot({
    required this.isSyncing,
    required this.lastSyncAt,
    required this.lastError,
    required this.pendingChangeCount,
    required this.conflictCount,
    required this.lastConflictAt,
  });
}

class SyncService {
  static const tableCategories = 'categories';
  static const tableTransactions = 'transactions';
  static const tableBills = 'bills';
  static const tableBudgets = 'budgets';
  static const tableDebts = 'debts';
  static const tableSplitBills = 'split_bills';

  final Isar _isar;
  final SupabaseClient? _client;
  bool _isSyncing = false;

  SyncService({required Isar isar, required SupabaseClient? client})
    : _isar = isar,
      _client = client;

  static Future<void> queueDelete(String table, String id) {
    return LocalPreferencesService.queuePendingDelete(table, id);
  }

  bool get isSyncing => _isSyncing;

  Future<bool> shouldSync({
    Duration minInterval = const Duration(minutes: 5),
  }) async {
    if (_isSyncing) return false;
    final lastSync = await LocalPreferencesService.getLastSyncAt();
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
      final lastSyncAt = await LocalPreferencesService.getLastSyncAt();

      await _pushCategories(user.id);
      await _pushTransactions(user.id);
      await _pushBills(user.id);
      await _pushBudgets(user.id);
      await _pushDebts(user.id);
      await _pushSplitBills(user.id);
      await _pushPendingDeletes(user.id);

      await _pullCategories(user.id, lastSyncAt);
      await _pullTransactions(user.id, lastSyncAt);
      await _pullBills(user.id, lastSyncAt);
      await _pullBudgets(user.id, lastSyncAt);
      await _pullDebts(user.id, lastSyncAt);
      await _pullSplitBills(user.id, lastSyncAt);

      await LocalPreferencesService.setLastSyncAt(DateTime.now());
      await LocalPreferencesService.setLastSyncError(null);
    } catch (e) {
      await LocalPreferencesService.setLastSyncError(e.toString());
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  Future<SyncStatusSnapshot> getStatusSnapshot() async {
    final pendingDeletes = await Future.wait([
      LocalPreferencesService.getPendingDeletes(tableCategories),
      LocalPreferencesService.getPendingDeletes(tableTransactions),
      LocalPreferencesService.getPendingDeletes(tableBills),
      LocalPreferencesService.getPendingDeletes(tableBudgets),
      LocalPreferencesService.getPendingDeletes(tableDebts),
      LocalPreferencesService.getPendingDeletes(tableSplitBills),
    ]);
    final conflicts = await LocalPreferencesService.getSyncConflicts();
    return SyncStatusSnapshot(
      isSyncing: _isSyncing,
      lastSyncAt: await LocalPreferencesService.getLastSyncAt(),
      lastError: await LocalPreferencesService.getLastSyncError(),
      conflictCount: conflicts.length,
      lastConflictAt: conflicts.isEmpty ? null : conflicts.first.detectedAt,
      pendingChangeCount:
          await _getUnsyncedCount() +
          pendingDeletes.fold<int>(0, (sum, items) => sum + items.length),
    );
  }

  Future<void> _pushCategories(String userId) async {
    final pendingDeleteIds = await LocalPreferencesService.getPendingDeleteIds(
      tableCategories,
    );
    final unsynced = await _isar.categoryModels
        .filter()
        .syncStatusEqualTo(false)
        .findAll();
    final candidates = unsynced
        .where((model) => !pendingDeleteIds.contains(model.id))
        .toList();
    if (candidates.isEmpty) return;

    final remoteRows = await _fetchRemoteRows(
      tableCategories,
      userId,
      candidates.map((item) => item.id ?? '').where((id) => id.isNotEmpty),
    );
    final rows = candidates
        .where(
          (item) => !_hasRemotePriority(item.updatedAt, remoteRows[item.id]),
        )
        .map((item) => _categoryToRow(item, userId))
        .toList();
    if (rows.isEmpty) return;

    await _client?.from(tableCategories).upsert(rows, onConflict: 'id');
    await _isar.writeTxn(() async {
      for (final model in candidates.where(
        (item) => !_hasRemotePriority(item.updatedAt, remoteRows[item.id]),
      )) {
        final updated = model.copyWith(
          syncStatus: true,
          updatedAt: DateTime.now(),
        );
        await _isar.categoryModels.put(updated..isarId = model.isarId);
        await LocalPreferencesService.clearSyncConflict(
          tableCategories,
          model.id!,
        );
      }
    });
  }

  Future<void> _pushTransactions(String userId) async {
    final pendingDeleteIds = await LocalPreferencesService.getPendingDeleteIds(
      tableTransactions,
    );
    final unsynced = await _isar.transactionModels
        .filter()
        .syncStatusEqualTo(false)
        .findAll();
    final candidates = unsynced
        .where((model) => !pendingDeleteIds.contains(model.id))
        .toList();
    if (candidates.isEmpty) return;

    final remoteRows = await _fetchRemoteRows(
      tableTransactions,
      userId,
      candidates.map((item) => item.id ?? '').where((id) => id.isNotEmpty),
    );
    final rows = candidates
        .where(
          (item) => !_hasRemotePriority(item.updatedAt, remoteRows[item.id]),
        )
        .map((item) => _transactionToRow(item, userId))
        .toList();
    if (rows.isEmpty) return;

    await _client?.from(tableTransactions).upsert(rows, onConflict: 'id');
    await _isar.writeTxn(() async {
      for (final model in candidates.where(
        (item) => !_hasRemotePriority(item.updatedAt, remoteRows[item.id]),
      )) {
        final updated = model.copyWith(
          syncStatus: true,
          updatedAt: DateTime.now(),
        );
        await _isar.transactionModels.put(updated..isarId = model.isarId);
        await LocalPreferencesService.clearSyncConflict(
          tableTransactions,
          model.id!,
        );
      }
    });
  }

  Future<void> _pushBills(String userId) async {
    final pendingDeleteIds = await LocalPreferencesService.getPendingDeleteIds(
      tableBills,
    );
    final unsynced = await _isar.billModels
        .filter()
        .syncStatusEqualTo(false)
        .findAll();
    final candidates = unsynced
        .where((model) => !pendingDeleteIds.contains(model.id))
        .toList();
    if (candidates.isEmpty) return;

    final remoteRows = await _fetchRemoteRows(
      tableBills,
      userId,
      candidates.map((item) => item.id ?? '').where((id) => id.isNotEmpty),
    );
    final rows = candidates
        .where(
          (item) => !_hasRemotePriority(item.updatedAt, remoteRows[item.id]),
        )
        .map((item) => _billToRow(item, userId))
        .toList();
    if (rows.isEmpty) return;

    await _client?.from(tableBills).upsert(rows, onConflict: 'id');
    await _isar.writeTxn(() async {
      for (final model in candidates.where(
        (item) => !_hasRemotePriority(item.updatedAt, remoteRows[item.id]),
      )) {
        final updated = model.copyWith(
          syncStatus: true,
          updatedAt: DateTime.now(),
        );
        await _isar.billModels.put(updated..isarId = model.isarId);
        await LocalPreferencesService.clearSyncConflict(tableBills, model.id!);
      }
    });
  }

  Future<void> _pushBudgets(String userId) async {
    final pendingDeleteIds = await LocalPreferencesService.getPendingDeleteIds(
      tableBudgets,
    );
    final unsynced = await _isar.budgetModels
        .filter()
        .syncStatusEqualTo(false)
        .findAll();
    final candidates = unsynced
        .where((model) => !pendingDeleteIds.contains(model.id))
        .toList();
    if (candidates.isEmpty) return;

    final remoteRows = await _fetchRemoteRows(
      tableBudgets,
      userId,
      candidates.map((item) => item.id ?? '').where((id) => id.isNotEmpty),
    );
    final rows = candidates
        .where(
          (item) => !_hasRemotePriority(item.updatedAt, remoteRows[item.id]),
        )
        .map((item) => _budgetToRow(item, userId))
        .toList();
    if (rows.isEmpty) return;

    await _client?.from(tableBudgets).upsert(rows, onConflict: 'id');
    await _isar.writeTxn(() async {
      for (final model in candidates.where(
        (item) => !_hasRemotePriority(item.updatedAt, remoteRows[item.id]),
      )) {
        final updated = model.copyWith(
          syncStatus: true,
          updatedAt: DateTime.now(),
        );
        await _isar.budgetModels.put(updated..isarId = model.isarId);
        await LocalPreferencesService.clearSyncConflict(
          tableBudgets,
          model.id!,
        );
      }
    });
  }

  Future<void> _pushDebts(String userId) async {
    final pendingDeleteIds = await LocalPreferencesService.getPendingDeleteIds(
      tableDebts,
    );
    final unsynced = await _isar.debtModels
        .filter()
        .syncStatusEqualTo(false)
        .findAll();
    final candidates = unsynced
        .where((model) => !pendingDeleteIds.contains(model.id))
        .toList();
    if (candidates.isEmpty) return;

    final remoteRows = await _fetchRemoteRows(
      tableDebts,
      userId,
      candidates.map((item) => item.id ?? '').where((id) => id.isNotEmpty),
    );
    final rows = candidates
        .where(
          (item) => !_hasRemotePriority(item.updatedAt, remoteRows[item.id]),
        )
        .map((item) => _debtToRow(item, userId))
        .toList();
    if (rows.isEmpty) return;

    await _client?.from(tableDebts).upsert(rows, onConflict: 'id');
    await _isar.writeTxn(() async {
      for (final model in candidates.where(
        (item) => !_hasRemotePriority(item.updatedAt, remoteRows[item.id]),
      )) {
        final updated = model.copyWith(
          syncStatus: true,
          updatedAt: DateTime.now(),
        );
        await _isar.debtModels.put(updated..isarId = model.isarId);
        await LocalPreferencesService.clearSyncConflict(tableDebts, model.id!);
      }
    });
  }

  Future<void> _pushSplitBills(String userId) async {
    final pendingDeleteIds = await LocalPreferencesService.getPendingDeleteIds(
      tableSplitBills,
    );
    final unsynced = await _isar.splitBillModels
        .filter()
        .syncStatusEqualTo(false)
        .findAll();
    final candidates = unsynced
        .where((model) => !pendingDeleteIds.contains(model.id))
        .toList();
    if (candidates.isEmpty) return;

    final remoteRows = await _fetchRemoteRows(
      tableSplitBills,
      userId,
      candidates.map((item) => item.id ?? '').where((id) => id.isNotEmpty),
    );
    final rows = candidates
        .where(
          (item) => !_hasRemotePriority(item.updatedAt, remoteRows[item.id]),
        )
        .map((item) => _splitBillToRow(item, userId))
        .toList();
    if (rows.isEmpty) return;

    await _client?.from(tableSplitBills).upsert(rows, onConflict: 'id');
    await _isar.writeTxn(() async {
      for (final model in candidates.where(
        (item) => !_hasRemotePriority(item.updatedAt, remoteRows[item.id]),
      )) {
        final updated = model.copyWith(
          syncStatus: true,
          updatedAt: DateTime.now(),
        );
        await _isar.splitBillModels.put(updated..isarId = model.isarId);
        await LocalPreferencesService.clearSyncConflict(
          tableSplitBills,
          model.id!,
        );
      }
    });
  }

  Future<void> _pushPendingDeletes(String userId) async {
    await _syncDeletesForTable(tableCategories, userId);
    await _syncDeletesForTable(tableTransactions, userId);
    await _syncDeletesForTable(tableBills, userId);
    await _syncDeletesForTable(tableBudgets, userId);
    await _syncDeletesForTable(tableDebts, userId);
    await _syncDeletesForTable(tableSplitBills, userId);
  }

  Future<void> _syncDeletesForTable(String table, String userId) async {
    final pendingDeletes = await LocalPreferencesService.getPendingDeletes(
      table,
    );
    for (final record in pendingDeletes) {
      try {
        await _client
            ?.from(table)
            .update({
              'deleted_at': record.deletedAt.toIso8601String(),
              'updated_at': record.deletedAt.toIso8601String(),
            })
            .eq('id', record.id)
            .eq('user_id', userId);
      } catch (_) {
        await _client
            ?.from(table)
            .delete()
            .eq('id', record.id)
            .eq('user_id', userId);
      }
      await LocalPreferencesService.removePendingDelete(table, record.id);
    }
  }

  Future<void> _pullCategories(String userId, DateTime? lastSyncAt) async {
    final pendingDeleteIds = await LocalPreferencesService.getPendingDeleteIds(
      tableCategories,
    );
    final rows = await _fetchPullRows(tableCategories, userId, lastSyncAt);
    await _isar.writeTxn(() async {
      for (final row in rows) {
        final id = row['id'] as String?;
        if (id == null || pendingDeleteIds.contains(id)) continue;
        if (_isDeletedRemotely(row)) {
          final existing = await _isar.categoryModels
              .where()
              .idEqualTo(id)
              .findFirst();
          if (existing?.isarId != null) {
            await _isar.categoryModels.delete(existing!.isarId!);
          }
          continue;
        }
        final model = _rowToCategory(row);
        final existing = await _isar.categoryModels
            .where()
            .idEqualTo(id)
            .findFirst();
        await _recordRemoteOverrideConflictIfNeeded(
          table: tableCategories,
          recordId: id,
          localSyncStatus: existing?.syncStatus ?? true,
          localUpdatedAt: existing?.updatedAt,
          remoteUpdatedAt: _parseDate(row['updated_at']),
        );
        await _isar.categoryModels.put(
          model.copyWith(syncStatus: true)..isarId = existing?.isarId,
        );
      }
    });
  }

  Future<void> _pullTransactions(String userId, DateTime? lastSyncAt) async {
    final pendingDeleteIds = await LocalPreferencesService.getPendingDeleteIds(
      tableTransactions,
    );
    final rows = await _fetchPullRows(tableTransactions, userId, lastSyncAt);
    await _isar.writeTxn(() async {
      for (final row in rows) {
        final id = row['id'] as String?;
        if (id == null || pendingDeleteIds.contains(id)) continue;
        if (_isDeletedRemotely(row)) {
          final existing = await _isar.transactionModels
              .where()
              .idEqualTo(id)
              .findFirst();
          if (existing?.isarId != null) {
            await _isar.transactionModels.delete(existing!.isarId!);
          }
          continue;
        }
        final model = _rowToTransaction(row);
        final existing = await _isar.transactionModels
            .where()
            .idEqualTo(id)
            .findFirst();
        await _recordRemoteOverrideConflictIfNeeded(
          table: tableTransactions,
          recordId: id,
          localSyncStatus: existing?.syncStatus ?? true,
          localUpdatedAt: existing?.updatedAt,
          remoteUpdatedAt: _parseDate(row['updated_at']),
        );
        await _isar.transactionModels.put(
          model.copyWith(syncStatus: true)..isarId = existing?.isarId,
        );
      }
    });
  }

  Future<void> _pullBills(String userId, DateTime? lastSyncAt) async {
    final pendingDeleteIds = await LocalPreferencesService.getPendingDeleteIds(
      tableBills,
    );
    final rows = await _fetchPullRows(tableBills, userId, lastSyncAt);
    await _isar.writeTxn(() async {
      for (final row in rows) {
        final id = row['id'] as String?;
        if (id == null || pendingDeleteIds.contains(id)) continue;
        if (_isDeletedRemotely(row)) {
          final existing = await _isar.billModels
              .where()
              .idEqualTo(id)
              .findFirst();
          if (existing?.isarId != null) {
            await _isar.billModels.delete(existing!.isarId!);
          }
          continue;
        }
        final model = _rowToBill(row);
        final existing = await _isar.billModels
            .where()
            .idEqualTo(id)
            .findFirst();
        await _recordRemoteOverrideConflictIfNeeded(
          table: tableBills,
          recordId: id,
          localSyncStatus: existing?.syncStatus ?? true,
          localUpdatedAt: existing?.updatedAt,
          remoteUpdatedAt: _parseDate(row['updated_at']),
        );
        await _isar.billModels.put(
          model.copyWith(syncStatus: true)..isarId = existing?.isarId,
        );
      }
    });
  }

  Future<void> _pullBudgets(String userId, DateTime? lastSyncAt) async {
    final pendingDeleteIds = await LocalPreferencesService.getPendingDeleteIds(
      tableBudgets,
    );
    final rows = await _fetchPullRows(tableBudgets, userId, lastSyncAt);
    await _isar.writeTxn(() async {
      for (final row in rows) {
        final id = row['id'] as String?;
        if (id == null || pendingDeleteIds.contains(id)) continue;
        if (_isDeletedRemotely(row)) {
          final existing = await _isar.budgetModels
              .where()
              .idEqualTo(id)
              .findFirst();
          if (existing?.isarId != null) {
            await _isar.budgetModels.delete(existing!.isarId!);
          }
          continue;
        }
        final model = _rowToBudget(row);
        final existing = await _isar.budgetModels
            .where()
            .idEqualTo(id)
            .findFirst();
        await _recordRemoteOverrideConflictIfNeeded(
          table: tableBudgets,
          recordId: id,
          localSyncStatus: existing?.syncStatus ?? true,
          localUpdatedAt: existing?.updatedAt,
          remoteUpdatedAt: _parseDate(row['updated_at']),
        );
        await _isar.budgetModels.put(
          model.copyWith(syncStatus: true)..isarId = existing?.isarId,
        );
      }
    });
  }

  Future<void> _pullDebts(String userId, DateTime? lastSyncAt) async {
    final pendingDeleteIds = await LocalPreferencesService.getPendingDeleteIds(
      tableDebts,
    );
    final rows = await _fetchPullRows(tableDebts, userId, lastSyncAt);
    await _isar.writeTxn(() async {
      for (final row in rows) {
        final id = row['id'] as String?;
        if (id == null || pendingDeleteIds.contains(id)) continue;
        if (_isDeletedRemotely(row)) {
          final existing = await _isar.debtModels
              .where()
              .idEqualTo(id)
              .findFirst();
          if (existing?.isarId != null) {
            await _isar.debtModels.delete(existing!.isarId!);
          }
          continue;
        }
        final model = _rowToDebt(row);
        final existing = await _isar.debtModels
            .where()
            .idEqualTo(id)
            .findFirst();
        await _recordRemoteOverrideConflictIfNeeded(
          table: tableDebts,
          recordId: id,
          localSyncStatus: existing?.syncStatus ?? true,
          localUpdatedAt: existing?.updatedAt,
          remoteUpdatedAt: _parseDate(row['updated_at']),
        );
        await _isar.debtModels.put(
          model.copyWith(syncStatus: true)..isarId = existing?.isarId,
        );
      }
    });
  }

  Future<void> _pullSplitBills(String userId, DateTime? lastSyncAt) async {
    final pendingDeleteIds = await LocalPreferencesService.getPendingDeleteIds(
      tableSplitBills,
    );
    final rows = await _fetchPullRows(tableSplitBills, userId, lastSyncAt);
    await _isar.writeTxn(() async {
      for (final row in rows) {
        final id = row['id'] as String?;
        if (id == null || pendingDeleteIds.contains(id)) continue;
        if (_isDeletedRemotely(row)) {
          final existing = await _isar.splitBillModels
              .where()
              .idEqualTo(id)
              .findFirst();
          if (existing?.isarId != null) {
            await _isar.splitBillModels.delete(existing!.isarId!);
          }
          continue;
        }
        final model = _rowToSplitBill(row);
        final existing = await _isar.splitBillModels
            .where()
            .idEqualTo(id)
            .findFirst();
        await _recordRemoteOverrideConflictIfNeeded(
          table: tableSplitBills,
          recordId: id,
          localSyncStatus: existing?.syncStatus ?? true,
          localUpdatedAt: existing?.updatedAt,
          remoteUpdatedAt: _parseDate(row['updated_at']),
        );
        await _isar.splitBillModels.put(
          model.copyWith(syncStatus: true)..isarId = existing?.isarId,
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> _fetchPullRows(
    String table,
    String userId,
    DateTime? lastSyncAt,
  ) async {
    final query = _client?.from(table).select().eq('user_id', userId);
    if (query == null) return const [];
    final result = lastSyncAt == null
        ? await query
        : await query.gt('updated_at', lastSyncAt.toIso8601String());
    return (result as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, Map<String, dynamic>>> _fetchRemoteRows(
    String table,
    String userId,
    Iterable<String> ids,
  ) async {
    final filteredIds = ids.where((id) => id.isNotEmpty).toList();
    if (filteredIds.isEmpty) return const {};
    final rows = await _client
        ?.from(table)
        .select()
        .eq('user_id', userId)
        .inFilter('id', filteredIds);
    final result = <String, Map<String, dynamic>>{};
    for (final row in (rows as List? ?? const [])) {
      final map = row as Map<String, dynamic>;
      final id = map['id'] as String?;
      if (id != null) result[id] = map;
    }
    return result;
  }

  bool _hasRemotePriority(
    DateTime? localUpdatedAt,
    Map<String, dynamic>? remoteRow,
  ) {
    if (remoteRow == null) return false;
    final remoteUpdatedAt = _parseDate(remoteRow['updated_at']);
    if (remoteUpdatedAt == null) return false;
    final local = localUpdatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return remoteUpdatedAt.isAfter(local);
  }

  bool _isDeletedRemotely(Map<String, dynamic> row) {
    return _parseDate(row['deleted_at']) != null;
  }

  Future<void> _recordRemoteOverrideConflictIfNeeded({
    required String table,
    required String recordId,
    required bool localSyncStatus,
    required DateTime? localUpdatedAt,
    required DateTime? remoteUpdatedAt,
  }) async {
    if (localSyncStatus) return;
    if (remoteUpdatedAt == null) return;
    final localTimestamp =
        localUpdatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    if (!remoteUpdatedAt.isAfter(localTimestamp)) return;

    await LocalPreferencesService.addSyncConflict(
      SyncConflictRecord(
        table: table,
        recordId: recordId,
        reason: 'remote_newer_than_local_unsynced',
        detectedAt: DateTime.now(),
        localUpdatedAt: localUpdatedAt,
        remoteUpdatedAt: remoteUpdatedAt,
      ),
    );
  }

  Future<int> _getUnsyncedCount() async {
    final lists = await Future.wait([
      _isar.categoryModels.filter().syncStatusEqualTo(false).findAll(),
      _isar.transactionModels.filter().syncStatusEqualTo(false).findAll(),
      _isar.billModels.filter().syncStatusEqualTo(false).findAll(),
      _isar.budgetModels.filter().syncStatusEqualTo(false).findAll(),
      _isar.debtModels.filter().syncStatusEqualTo(false).findAll(),
      _isar.splitBillModels.filter().syncStatusEqualTo(false).findAll(),
    ]);
    return lists.fold<int>(0, (sum, items) => sum + items.length);
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
      'deleted_at': null,
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
      'deleted_at': null,
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
      'deleted_at': null,
    };
  }

  Map<String, dynamic> _budgetToRow(BudgetModel model, String userId) {
    return {
      'id': model.id,
      'user_id': userId,
      'id_kategori': model.idKategori,
      'nama_kategori': model.namaKategori,
      'limit_amount': model.limit,
      'period': model.period,
      'month': model.month,
      'year': model.year,
      'created_at': model.createdAt?.toIso8601String(),
      'updated_at': model.updatedAt?.toIso8601String(),
      'deleted_at': null,
    };
  }

  Map<String, dynamic> _debtToRow(DebtModel model, String userId) {
    return {
      'id': model.id,
      'user_id': userId,
      'person': model.person,
      'amount': model.amount,
      'date': model.date?.toIso8601String(),
      'notes': model.notes,
      'type': model.type,
      'is_settled': model.isSettled,
      'settled_at': model.settledAt?.toIso8601String(),
      'created_at': model.createdAt?.toIso8601String(),
      'updated_at': model.updatedAt?.toIso8601String(),
      'deleted_at': null,
    };
  }

  Map<String, dynamic> _splitBillToRow(SplitBillModel model, String userId) {
    return {
      'id': model.id,
      'user_id': userId,
      'title': model.title,
      'total': model.total,
      'is_equal_split': model.isEqualSplit,
      'participant_names': model.participantNames,
      'participant_amounts': model.participantAmounts,
      'paid_participant_names': model.paidParticipantNames,
      'is_settled': model.isSettled,
      'created_at': model.createdAt?.toIso8601String(),
      'updated_at': model.updatedAt?.toIso8601String(),
      'deleted_at': null,
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

  BudgetModel _rowToBudget(Map<String, dynamic> row) {
    return BudgetModel(
      id: row['id'] as String?,
      idKategori: row['id_kategori'] as String? ?? '',
      namaKategori: row['nama_kategori'] as String? ?? '',
      limit: (row['limit_amount'] as num?)?.toDouble() ?? 0,
      period: row['period'] as String? ?? 'monthly',
      month: (row['month'] as num?)?.toInt() ?? DateTime.now().month,
      year: (row['year'] as num?)?.toInt() ?? DateTime.now().year,
      createdAt: _parseDate(row['created_at']),
      updatedAt: _parseDate(row['updated_at']),
      syncStatus: true,
    );
  }

  DebtModel _rowToDebt(Map<String, dynamic> row) {
    return DebtModel(
      id: row['id'] as String?,
      person: row['person'] as String? ?? '',
      amount: (row['amount'] as num?)?.toDouble() ?? 0,
      date: _parseDate(row['date']) ?? DateTime.now(),
      notes: row['notes'] as String?,
      type: row['type'] as String? ?? 'i_owe',
      isSettled: row['is_settled'] as bool? ?? false,
      settledAt: _parseDate(row['settled_at']),
      createdAt: _parseDate(row['created_at']),
      updatedAt: _parseDate(row['updated_at']),
      syncStatus: true,
    );
  }

  SplitBillModel _rowToSplitBill(Map<String, dynamic> row) {
    return SplitBillModel(
      id: row['id'] as String?,
      title: row['title'] as String? ?? '',
      total: (row['total'] as num?)?.toDouble() ?? 0,
      isEqualSplit: row['is_equal_split'] as bool? ?? true,
      participantNames: _stringList(row['participant_names']),
      participantAmounts: _doubleList(row['participant_amounts']),
      paidParticipantNames: _stringList(row['paid_participant_names']),
      isSettled: row['is_settled'] as bool? ?? false,
      createdAt: _parseDate(row['created_at']),
      updatedAt: _parseDate(row['updated_at']),
      syncStatus: true,
    );
  }

  List<String> _stringList(dynamic value) {
    if (value is List) return value.map((item) => item.toString()).toList();
    return const [];
  }

  List<double> _doubleList(dynamic value) {
    if (value is List) {
      return value
          .map(
            (item) =>
                item is num ? item.toDouble() : double.tryParse('$item') ?? 0,
          )
          .toList();
    }
    return const [];
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
