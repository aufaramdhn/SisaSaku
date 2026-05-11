import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/providers/isar_provider.dart';
import 'package:sisasaku/features/bill/data/datasources/bill_local_datasource.dart';
import 'package:sisasaku/features/bill/data/repositories/bill_repository_impl.dart';
import 'package:sisasaku/features/bill/domain/entities/bill_entity.dart';
import 'package:sisasaku/features/bill/domain/repositories/bill_repository.dart';
import 'package:sisasaku/core/enums.dart';

/// Provider untuk BillLocalDatasource
final billLocalDatasourceProvider = FutureProvider<BillLocalDatasource>((
  ref,
) async {
  final isar = ref.watch(isarProvider);
  return BillLocalDatasource(isar);
});

/// Provider untuk BillRepository
final billRepositoryProvider = FutureProvider<BillRepository>((ref) async {
  final datasource = await ref.watch(billLocalDatasourceProvider.future);
  return BillRepositoryImpl(datasource);
});

/// Provider untuk daftar tagihan
final billsProvider = StreamProvider<List<BillEntity>>((ref) async* {
  final repository = await ref.watch(billRepositoryProvider.future);
  yield await repository.getBills();
});

/// Provider untuk tagihan by ID
final billByIdProvider = FutureProvider.family<BillEntity?, String>((
  ref,
  billId,
) async {
  final repository = await ref.watch(billRepositoryProvider.future);
  return repository.getBillById(billId);
});

/// Provider untuk tagihan terdekat
final upcomingBillsProvider = StreamProvider<List<BillEntity>>((ref) async* {
  final repository = await ref.watch(billRepositoryProvider.future);
  yield await repository.getUpcomingBills();
});

/// Provider untuk tagihan yang overdue
final overdueBillsProvider = StreamProvider<List<BillEntity>>((ref) async* {
  final repository = await ref.watch(billRepositoryProvider.future);
  yield await repository.getOverdueBills();
});

/// Provider untuk tagihan by status
final billsByStatusProvider =
    StreamProvider.family<List<BillEntity>, BillStatus>((ref, status) async* {
      final repository = await ref.watch(billRepositoryProvider.future);
      yield await repository.getBillsByStatus(status);
    });

/// Provider untuk add tagihan
final addBillProvider = FutureProvider.family<BillEntity, BillEntity>((
  ref,
  bill,
) async {
  final repository = await ref.watch(billRepositoryProvider.future);
  return repository.addBill(bill);
});

/// Provider untuk update tagihan
final updateBillProvider = FutureProvider.family<BillEntity, BillEntity>((
  ref,
  bill,
) async {
  final repository = await ref.watch(billRepositoryProvider.future);
  return repository.updateBill(bill);
});

/// Provider untuk update status tagihan
final updateBillStatusProvider =
    FutureProvider.family<BillEntity, (String, BillStatus)>((
      ref,
      params,
    ) async {
      final (billId, newStatus) = params;
      final repository = await ref.watch(billRepositoryProvider.future);
      return repository.updateBillStatus(billId, newStatus);
    });

/// Provider untuk delete tagihan
final deleteBillProvider = FutureProvider.family<void, String>((
  ref,
  billId,
) async {
  final repository = await ref.watch(billRepositoryProvider.future);
  return repository.deleteBill(billId);
});
