import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/providers/isar_provider.dart';
import 'package:sisasaku/features/debt/data/datasources/debt_local_datasource.dart';
import 'package:sisasaku/features/debt/data/repositories/debt_repository_impl.dart';
import 'package:sisasaku/features/debt/domain/entities/debt_entity.dart';
import 'package:sisasaku/features/debt/domain/repositories/debt_repository.dart';

final debtLocalDatasourceProvider = FutureProvider<DebtLocalDatasource>((
  ref,
) async {
  final isar = ref.watch(isarProvider);
  return DebtLocalDatasource(isar);
});

final debtRepositoryProvider = FutureProvider<DebtRepository>((ref) async {
  final datasource = await ref.watch(debtLocalDatasourceProvider.future);
  return DebtRepositoryImpl(datasource);
});

final debtsProvider = StreamProvider<List<DebtEntity>>((ref) {
  final repositoryAsync = ref.watch(debtRepositoryProvider);
  return repositoryAsync.when(
    data: (repo) => repo.watchDebts(),
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.error(err, stack),
  );
});

final addDebtProvider = FutureProvider.family<DebtEntity, DebtEntity>((
  ref,
  debt,
) async {
  final repository = await ref.watch(debtRepositoryProvider.future);
  return repository.addDebt(debt);
});

final updateDebtProvider = FutureProvider.family<DebtEntity, DebtEntity>((
  ref,
  debt,
) async {
  final repository = await ref.watch(debtRepositoryProvider.future);
  return repository.updateDebt(debt);
});

final updateDebtSettlementProvider =
    FutureProvider.family<DebtEntity, (String, bool)>((ref, params) async {
      final repository = await ref.watch(debtRepositoryProvider.future);
      return repository.updateDebtSettlement(params.$1, params.$2);
    });

final deleteDebtProvider = FutureProvider.family<void, String>((ref, id) async {
  final repository = await ref.watch(debtRepositoryProvider.future);
  return repository.deleteDebt(id);
});
