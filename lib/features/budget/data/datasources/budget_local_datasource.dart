import 'package:isar/isar.dart';
import 'package:sisasaku/core/errors/exceptions.dart';
import 'package:sisasaku/core/services/sync_service.dart';
import 'package:sisasaku/features/budget/data/models/budget_model.dart';

class BudgetLocalDatasource {
  final Isar isar;

  BudgetLocalDatasource(this.isar);

  Future<List<BudgetModel>> getBudgets() async {
    try {
      final budgets = await isar.budgetModels.where().findAll();
      budgets.sort(
        (a, b) => (a.namaKategori ?? '').compareTo(b.namaKategori ?? ''),
      );
      return budgets;
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil anggaran: $e');
    }
  }

  Stream<List<BudgetModel>> watchBudgets() {
    try {
      return isar.budgetModels.where().watch(fireImmediately: true).map((
        budgets,
      ) {
        budgets.sort(
          (a, b) => (a.namaKategori ?? '').compareTo(b.namaKategori ?? ''),
        );
        return budgets;
      });
    } catch (e) {
      throw DatabaseException(message: 'Gagal memantau anggaran: $e');
    }
  }

  Future<BudgetModel?> getBudgetById(String id) async {
    try {
      return await isar.budgetModels.where().idEqualTo(id).findFirst();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil anggaran: $e');
    }
  }

  Future<BudgetModel> addBudget(BudgetModel budget) async {
    try {
      await isar.writeTxn(() async {
        await isar.budgetModels.put(budget);
      });
      return budget;
    } catch (e) {
      throw DatabaseException(message: 'Gagal menambah anggaran: $e');
    }
  }

  Future<BudgetModel> updateBudget(BudgetModel budget) async {
    try {
      final existing = await getBudgetById(budget.id ?? '');
      final updated = budget.copyWith(
        updatedAt: DateTime.now(),
        syncStatus: false,
      );
      updated.isarId = existing?.isarId ?? budget.isarId;
      await isar.writeTxn(() async {
        await isar.budgetModels.put(updated);
      });
      return updated;
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengupdate anggaran: $e');
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      final budget = await getBudgetById(id);
      if (budget != null && budget.isarId != null) {
        await SyncService.queueDelete(SyncService.tableBudgets, id);
        await isar.writeTxn(() async {
          await isar.budgetModels.delete(budget.isarId!);
        });
      }
    } catch (e) {
      throw DatabaseException(message: 'Gagal menghapus anggaran: $e');
    }
  }

  Future<List<BudgetModel>> getUnsyncedBudgets() async {
    try {
      final budgets = await isar.budgetModels.where().findAll();
      return budgets.where((budget) => !budget.syncStatus).toList();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil anggaran: $e');
    }
  }
}
