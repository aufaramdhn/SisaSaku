import 'package:isar/isar.dart';
import 'package:sisasaku/features/bill/data/models/bill_model.dart';
import 'package:sisasaku/core/errors/exceptions.dart';
import 'package:sisasaku/core/enums.dart';

/// Local datasource untuk Bill (Isar)
class BillLocalDatasource {
  final Isar isar;

  BillLocalDatasource(this.isar);

  /// Get semua tagihan
  Future<List<BillModel>> getBills() async {
    try {
      final bills = await isar.billModels.where().findAll();
      bills.sort(
        (a, b) => (a.tanggalJatuhTempo ?? DateTime.now()).compareTo(
          b.tanggalJatuhTempo ?? DateTime.now(),
        ),
      );
      return bills;
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil tagihan: $e');
    }
  }

  /// Get tagihan by ID
  Future<BillModel?> getBillById(String id) async {
    try {
      return await isar.billModels.where().idEqualTo(id).findFirst();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil tagihan: $e');
    }
  }

  /// Get tagihan by status
  Future<List<BillModel>> getBillsByStatus(String status) async {
    try {
      final bills = await isar.billModels.where().findAll();
      return bills.where((bill) => bill.status == status).toList()..sort(
        (a, b) => (a.tanggalJatuhTempo ?? DateTime.now()).compareTo(
          b.tanggalJatuhTempo ?? DateTime.now(),
        ),
      );
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil tagihan: $e');
    }
  }

  /// Get tagihan terdekat
  Future<List<BillModel>> getUpcomingBills({int limit = 5}) async {
    try {
      final bills = await isar.billModels.where().findAll();
      final upcomingBills =
          bills
              .where(
                (bill) =>
                    bill.status == BillStatus.upcoming.label ||
                    bill.status == BillStatus.pending.label,
              )
              .toList()
            ..sort(
              (a, b) => (a.tanggalJatuhTempo ?? DateTime.now()).compareTo(
                b.tanggalJatuhTempo ?? DateTime.now(),
              ),
            );
      return upcomingBills.take(limit).toList();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil tagihan terdekat: $e');
    }
  }

  /// Get tagihan yang overdue
  Future<List<BillModel>> getOverdueBills() async {
    try {
      final bills = await isar.billModels.where().findAll();
      return bills
          .where((bill) => bill.status == BillStatus.overdue.label)
          .toList()
        ..sort(
          (a, b) => (a.tanggalJatuhTempo ?? DateTime.now()).compareTo(
            b.tanggalJatuhTempo ?? DateTime.now(),
          ),
        );
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil tagihan overdue: $e');
    }
  }

  /// Add tagihan
  Future<BillModel> addBill(BillModel bill) async {
    try {
      await isar.writeTxn(() async {
        await isar.billModels.put(bill);
      });
      return bill;
    } catch (e) {
      throw DatabaseException(message: 'Gagal menambah tagihan: $e');
    }
  }

  /// Update tagihan
  Future<BillModel> updateBill(BillModel bill) async {
    try {
      final updated = bill.copyWith(updatedAt: DateTime.now());
      await isar.writeTxn(() async {
        await isar.billModels.put(updated);
      });
      return updated;
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengupdate tagihan: $e');
    }
  }

  /// Update status tagihan
  Future<BillModel> updateBillStatus(String billId, String newStatus) async {
    try {
      final bill = await getBillById(billId);
      if (bill == null) {
        throw DatabaseException(message: 'Tagihan tidak ditemukan');
      }

      final updated = bill.copyWith(
        status: newStatus,
        tanggalPembayaran: newStatus == BillStatus.paid.label
            ? DateTime.now()
            : null,
        updatedAt: DateTime.now(),
      );
      return updateBill(updated);
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengupdate status tagihan: $e');
    }
  }

  /// Delete tagihan
  Future<void> deleteBill(String id) async {
    try {
      final bill = await getBillById(id);
      if (bill != null) {
        await isar.writeTxn(() async {
          await isar.billModels.delete(bill.isarId!);
        });
      }
    } catch (e) {
      throw DatabaseException(message: 'Gagal menghapus tagihan: $e');
    }
  }

  /// Get tagihan yang belum tersinkronisasi
  Future<List<BillModel>> getUnsyncedBills() async {
    try {
      final bills = await isar.billModels.where().findAll();
      return bills.where((bill) => bill.syncStatus == false).toList();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil tagihan: $e');
    }
  }

  /// Mark bill as synced
  Future<void> markBillAsSynced(String id) async {
    try {
      final bill = await getBillById(id);
      if (bill != null) {
        await updateBill(bill.copyWith(syncStatus: true));
      }
    } catch (e) {
      throw DatabaseException(message: 'Gagal mensinkronisasi tagihan: $e');
    }
  }
}
