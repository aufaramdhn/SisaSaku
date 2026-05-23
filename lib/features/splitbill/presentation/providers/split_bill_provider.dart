import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/providers/isar_provider.dart';
import 'package:sisasaku/features/splitbill/data/datasources/split_bill_local_datasource.dart';
import 'package:sisasaku/features/splitbill/data/repositories/split_bill_repository_impl.dart';
import 'package:sisasaku/features/splitbill/domain/entities/split_bill_entity.dart';
import 'package:sisasaku/features/splitbill/domain/repositories/split_bill_repository.dart';

final splitBillLocalDatasourceProvider =
    FutureProvider<SplitBillLocalDatasource>((ref) async {
      final isar = ref.watch(isarProvider);
      return SplitBillLocalDatasource(isar);
    });

final splitBillRepositoryProvider = FutureProvider<SplitBillRepository>((
  ref,
) async {
  final datasource = await ref.watch(splitBillLocalDatasourceProvider.future);
  return SplitBillRepositoryImpl(datasource);
});

final splitBillsProvider = StreamProvider<List<SplitBillEntity>>((ref) {
  final repositoryAsync = ref.watch(splitBillRepositoryProvider);
  return repositoryAsync.when(
    data: (repo) => repo.watchSplitBills(),
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.error(err, stack),
  );
});

final splitBillByIdProvider = StreamProvider.family<SplitBillEntity?, String>((
  ref,
  id,
) {
  final repositoryAsync = ref.watch(splitBillRepositoryProvider);
  return repositoryAsync.when(
    data: (repo) => repo.watchSplitBills().map(
      (items) => items.where((item) => item.id == id).firstOrNull,
    ),
    loading: () => Stream.value(null),
    error: (err, stack) => Stream.error(err, stack),
  );
});

final addSplitBillProvider =
    FutureProvider.family<SplitBillEntity, SplitBillEntity>((
      ref,
      splitBill,
    ) async {
      final repository = await ref.watch(splitBillRepositoryProvider.future);
      return repository.addSplitBill(splitBill);
    });

final updateSplitBillProvider =
    FutureProvider.family<SplitBillEntity, SplitBillEntity>((
      ref,
      splitBill,
    ) async {
      final repository = await ref.watch(splitBillRepositoryProvider.future);
      return repository.updateSplitBill(splitBill);
    });

final markParticipantPaidProvider =
    FutureProvider.family<SplitBillEntity, (String, String, bool)>((
      ref,
      params,
    ) async {
      final repository = await ref.watch(splitBillRepositoryProvider.future);
      return repository.markParticipantPaid(params.$1, params.$2, params.$3);
    });

final deleteSplitBillProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final repository = await ref.watch(splitBillRepositoryProvider.future);
  return repository.deleteSplitBill(id);
});
