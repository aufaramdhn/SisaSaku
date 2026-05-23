import 'package:sisasaku/features/budget/domain/entities/budget_entity.dart';

abstract class BudgetRepository {
  Future<List<BudgetEntity>> getBudgets();
  Stream<List<BudgetEntity>> watchBudgets();
  Future<BudgetEntity?> getBudgetById(String id);
  Future<BudgetEntity> addBudget(BudgetEntity budget);
  Future<BudgetEntity> updateBudget(BudgetEntity budget);
  Future<void> deleteBudget(String id);
  Future<List<BudgetEntity>> getUnsyncedBudgets();
}
