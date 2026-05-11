import 'package:sisasaku/features/bill/domain/entities/bill_entity.dart';
import 'package:sisasaku/core/enums.dart';

/// Abstract repository untuk Bill
abstract class BillRepository {
  /// Get semua tagihan
  Future<List<BillEntity>> getBills();

  /// Get tagihan by ID
  Future<BillEntity?> getBillById(String id);

  /// Get tagihan by status
  Future<List<BillEntity>> getBillsByStatus(BillStatus status);

  /// Get tagihan terdekat (upcoming/pending)
  Future<List<BillEntity>> getUpcomingBills({int limit = 5});

  /// Get tagihan yang overdue
  Future<List<BillEntity>> getOverdueBills();

  /// Add tagihan baru
  Future<BillEntity> addBill(BillEntity bill);

  /// Update tagihan
  Future<BillEntity> updateBill(BillEntity bill);

  /// Update status tagihan
  Future<BillEntity> updateBillStatus(String billId, BillStatus newStatus);

  /// Delete tagihan
  Future<void> deleteBill(String id);

  /// Get tagihan yang belum tersinkronisasi
  Future<List<BillEntity>> getUnsyncedBills();
}
