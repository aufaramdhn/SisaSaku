import 'package:isar/isar.dart';
import 'package:sisasaku/core/errors/exceptions.dart';
import 'package:sisasaku/core/services/sync_service.dart';
import 'package:sisasaku/features/debt/data/models/debt_model.dart';

class DebtLocalDatasource {
  final Isar isar;

  DebtLocalDatasource(this.isar);

  Future<List<DebtModel>> getDebts() async {
    try {
      return await isar.debtModels.where().sortByDateDesc().findAll();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil hutang piutang: $e');
    }
  }

  Stream<List<DebtModel>> watchDebts() {
    try {
      return isar.debtModels.where().watch(fireImmediately: true).map((debts) {
        debts.sort(
          (a, b) =>
              (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()),
        );
        return debts;
      });
    } catch (e) {
      throw DatabaseException(message: 'Gagal memantau hutang piutang: $e');
    }
  }

  Future<DebtModel?> getDebtById(String id) async {
    try {
      return await isar.debtModels.where().idEqualTo(id).findFirst();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil hutang piutang: $e');
    }
  }

  Future<DebtModel> addDebt(DebtModel debt) async {
    try {
      await isar.writeTxn(() async {
        await isar.debtModels.put(debt);
      });
      return debt;
    } catch (e) {
      throw DatabaseException(message: 'Gagal menambah hutang piutang: $e');
    }
  }

  Future<DebtModel> updateDebt(DebtModel debt) async {
    try {
      final existing = await getDebtById(debt.id ?? '');
      final updated = debt.copyWith(
        updatedAt: DateTime.now(),
        syncStatus: false,
      );
      updated.isarId = existing?.isarId ?? debt.isarId;
      await isar.writeTxn(() async {
        await isar.debtModels.put(updated);
      });
      return updated;
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengupdate hutang piutang: $e');
    }
  }

  Future<DebtModel> updateDebtSettlement(String id, bool isSettled) async {
    final debt = await getDebtById(id);
    if (debt == null) {
      throw DatabaseException(message: 'Hutang piutang tidak ditemukan');
    }
    return updateDebt(
      debt.copyWith(
        isSettled: isSettled,
        settledAt: isSettled ? DateTime.now() : null,
      ),
    );
  }

  Future<void> deleteDebt(String id) async {
    try {
      final debt = await getDebtById(id);
      if (debt != null && debt.isarId != null) {
        await SyncService.queueDelete(SyncService.tableDebts, id);
        await isar.writeTxn(() async {
          await isar.debtModels.delete(debt.isarId!);
        });
      }
    } catch (e) {
      throw DatabaseException(message: 'Gagal menghapus hutang piutang: $e');
    }
  }

  Future<List<DebtModel>> getUnsyncedDebts() async {
    try {
      final debts = await isar.debtModels.where().findAll();
      return debts.where((debt) => !debt.syncStatus).toList();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil hutang piutang: $e');
    }
  }
}
