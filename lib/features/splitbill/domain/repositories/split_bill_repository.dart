import 'package:sisasaku/features/splitbill/domain/entities/split_bill_entity.dart';

abstract class SplitBillRepository {
  Future<List<SplitBillEntity>> getSplitBills();
  Stream<List<SplitBillEntity>> watchSplitBills();
  Future<SplitBillEntity?> getSplitBillById(String id);
  Future<SplitBillEntity> addSplitBill(SplitBillEntity splitBill);
  Future<SplitBillEntity> updateSplitBill(SplitBillEntity splitBill);
  Future<SplitBillEntity> markParticipantPaid(
    String id,
    String participantName,
    bool isPaid,
  );
  Future<void> deleteSplitBill(String id);
  Future<List<SplitBillEntity>> getUnsyncedSplitBills();
}
