import 'package:sisasaku/features/debt/domain/entities/debt_entity.dart';

abstract class DebtRepository {
  Future<List<DebtEntity>> getDebts();
  Stream<List<DebtEntity>> watchDebts();
  Future<DebtEntity?> getDebtById(String id);
  Future<DebtEntity> addDebt(DebtEntity debt);
  Future<DebtEntity> updateDebt(DebtEntity debt);
  Future<DebtEntity> updateDebtSettlement(String id, bool isSettled);
  Future<void> deleteDebt(String id);
  Future<List<DebtEntity>> getUnsyncedDebts();
}
