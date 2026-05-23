import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/providers/isar_provider.dart';
import 'package:sisasaku/features/budget/data/datasources/budget_local_datasource.dart';
import 'package:sisasaku/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:sisasaku/features/budget/domain/entities/budget_entity.dart';
import 'package:sisasaku/features/budget/domain/repositories/budget_repository.dart';

final budgetLocalDatasourceProvider = FutureProvider<BudgetLocalDatasource>((
  ref,
) async {
  final isar = ref.watch(isarProvider);
  return BudgetLocalDatasource(isar);
});

final budgetRepositoryProvider = FutureProvider<BudgetRepository>((ref) async {
  final datasource = await ref.watch(budgetLocalDatasourceProvider.future);
  return BudgetRepositoryImpl(datasource);
});

final budgetsProvider = StreamProvider<List<BudgetEntity>>((ref) {
  final repositoryAsync = ref.watch(budgetRepositoryProvider);
  return repositoryAsync.when(
    data: (repo) => repo.watchBudgets(),
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.error(err, stack),
  );
});

final addBudgetProvider = FutureProvider.family<BudgetEntity, BudgetEntity>((
  ref,
  budget,
) async {
  final repository = await ref.watch(budgetRepositoryProvider.future);
  return repository.addBudget(budget);
});

final updateBudgetProvider = FutureProvider.family<BudgetEntity, BudgetEntity>((
  ref,
  budget,
) async {
  final repository = await ref.watch(budgetRepositoryProvider.future);
  return repository.updateBudget(budget);
});

final deleteBudgetProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final repository = await ref.watch(budgetRepositoryProvider.future);
  return repository.deleteBudget(id);
});
