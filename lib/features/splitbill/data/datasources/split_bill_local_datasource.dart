import 'package:isar/isar.dart';
import 'package:sisasaku/core/errors/exceptions.dart';
import 'package:sisasaku/core/services/sync_service.dart';
import 'package:sisasaku/features/splitbill/data/models/split_bill_model.dart';

class SplitBillLocalDatasource {
  final Isar isar;

  SplitBillLocalDatasource(this.isar);

  Future<List<SplitBillModel>> getSplitBills() async {
    try {
      final bills = await isar.splitBillModels.where().findAll();
      bills.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );
      return bills;
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil bagi rata: $e');
    }
  }

  Stream<List<SplitBillModel>> watchSplitBills() {
    try {
      return isar.splitBillModels.where().watch(fireImmediately: true).map((
        bills,
      ) {
        bills.sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );
        return bills;
      });
    } catch (e) {
      throw DatabaseException(message: 'Gagal memantau bagi rata: $e');
    }
  }

  Future<SplitBillModel?> getSplitBillById(String id) async {
    try {
      return await isar.splitBillModels.where().idEqualTo(id).findFirst();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil bagi rata: $e');
    }
  }

  Future<SplitBillModel> addSplitBill(SplitBillModel splitBill) async {
    try {
      await isar.writeTxn(() async {
        await isar.splitBillModels.put(splitBill);
      });
      return splitBill;
    } catch (e) {
      throw DatabaseException(message: 'Gagal menambah bagi rata: $e');
    }
  }

  Future<SplitBillModel> updateSplitBill(SplitBillModel splitBill) async {
    try {
      final existing = await getSplitBillById(splitBill.id ?? '');
      final updated = splitBill.copyWith(
        updatedAt: DateTime.now(),
        syncStatus: false,
      );
      updated.isarId = existing?.isarId ?? splitBill.isarId;
      await isar.writeTxn(() async {
        await isar.splitBillModels.put(updated);
      });
      return updated;
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengupdate bagi rata: $e');
    }
  }

  Future<SplitBillModel> markParticipantPaid(
    String id,
    String participantName,
    bool isPaid,
  ) async {
    final splitBill = await getSplitBillById(id);
    if (splitBill == null) {
      throw DatabaseException(message: 'Bagi rata tidak ditemukan');
    }

    final paid = [...splitBill.paidParticipantNames];
    if (isPaid && !paid.contains(participantName)) {
      paid.add(participantName);
    }
    if (!isPaid) {
      paid.remove(participantName);
    }
    return updateSplitBill(splitBill.copyWith(paidParticipantNames: paid));
  }

  Future<void> deleteSplitBill(String id) async {
    try {
      final splitBill = await getSplitBillById(id);
      if (splitBill != null && splitBill.isarId != null) {
        await SyncService.queueDelete(SyncService.tableSplitBills, id);
        await isar.writeTxn(() async {
          await isar.splitBillModels.delete(splitBill.isarId!);
        });
      }
    } catch (e) {
      throw DatabaseException(message: 'Gagal menghapus bagi rata: $e');
    }
  }

  Future<List<SplitBillModel>> getUnsyncedSplitBills() async {
    try {
      final bills = await isar.splitBillModels.where().findAll();
      return bills.where((bill) => !bill.syncStatus).toList();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil bagi rata: $e');
    }
  }
}
