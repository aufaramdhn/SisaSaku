import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/core/services/notification_service.dart';
import 'package:sisasaku/core/theme/app_color_extension.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';
import 'package:sisasaku/core/utils/date_formatter.dart';
import 'package:sisasaku/features/bill/domain/entities/bill_entity.dart';
import 'package:sisasaku/features/bill/presentation/providers/bill_provider.dart';
import 'package:sisasaku/routes/app_router.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';

class BillDetailPage extends ConsumerWidget {
  final String billId;

  const BillDetailPage({super.key, required this.billId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billAsync = ref.watch(billByIdProvider(billId));

    return billAsync.when(
      data: (bill) {
        if (bill == null) {
          return _buildMissingState(context);
        }

        return _buildScaffold(context, ref, bill);
      },
      loading: () => Scaffold(
        backgroundColor: context.colors.bgSecondary,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: context.colors.bgSecondary,
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, WidgetRef ref, BillEntity bill) {
    final statusColor = _statusColor(bill.status);

    return Scaffold(
      backgroundColor: context.colors.bgSecondary,
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.arrow_back,
                          color: context.colors.textSecondary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: context.colors.bgPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Detail Tagihan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.push(
                              AppRouter.editBill.replaceAll(':id', bill.id),
                            ),
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.primaryColor,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: context.colors.bgPrimary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          IconButton(
                            onPressed: () => _deleteBill(context, ref, bill),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.dangerColor,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.dangerLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.xl),
                        _buildAmountCard(context, bill, statusColor),
                        const SizedBox(height: AppSpacing.lg),
                        _buildInfoCard(context, bill, statusColor),
                        if (bill.status != BillStatus.paid) ...[
                          const SizedBox(height: AppSpacing.xl),
                          _buildMarkPaidButton(context, ref, bill),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context, BillEntity bill, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.colors.bgPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            bill.nama,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CurrencyFormatter.format(bill.nominal ?? 0),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w800,
              fontSize: 36,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, BillEntity bill, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.bgPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            context,
            icon: _statusIcon(bill.status),
            iconColor: statusColor,
            label: 'Status',
            value: _statusLabel(bill.status),
          ),
          Divider(height: 32, color: context.colors.borderColor),
          _buildInfoRow(
            context,
            icon: Icons.calendar_today_outlined,
            iconColor: AppColors.primaryColor,
            label: 'Jatuh Tempo',
            value: DateFormatter.formatDate(bill.tanggalJatuhTempo),
          ),
          Divider(height: 32, color: context.colors.borderColor),
          _buildInfoRow(
            context,
            icon: Icons.notifications_active_outlined,
            iconColor: AppColors.warningDark,
            label: 'Pengingat',
            value: _reminderLabel(bill),
          ),
          Divider(height: 32, color: context.colors.borderColor),
          _buildInfoRow(
            context,
            icon: Icons.notes_outlined,
            iconColor: context.colors.textSecondary,
            label: 'Catatan',
            value: (bill.deskripsi?.isNotEmpty ?? false)
                ? bill.deskripsi!
                : 'Tidak ada catatan',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarkPaidButton(
    BuildContext context,
    WidgetRef ref,
    BillEntity bill,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: () => _markBillPaid(context, ref, bill),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: const Text(
          'Tandai Lunas',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildMissingState(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgSecondary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tagihan tidak ditemukan'),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteBill(
    BuildContext context,
    WidgetRef ref,
    BillEntity bill,
  ) async {
    final confirmed = await FeedbackDialog.showConfirm(
      context,
      title: 'Hapus Tagihan',
      message: 'Tagihan akan dihapus permanen. Lanjutkan?',
      actionLabel: 'Hapus',
    );

    if (!context.mounted || !confirmed) return;

    try {
      final localDatasource = await ref.read(
        billLocalDatasourceProvider.future,
      );
      final billModel = await localDatasource.getBillById(bill.id);
      if (billModel?.isarId != null) {
        await NotificationService().cancelBillReminder(billModel!.isarId!);
      }

      await ref.read(deleteBillProvider(bill.id).future);

      if (context.mounted) {
        await FeedbackDialog.showSuccess<void>(
          context,
          title: 'Tagihan dihapus',
          message: 'Data tagihan sudah dihapus.',
        );
      }
      if (context.mounted) {
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        await FeedbackDialog.showError<void>(
          context,
          title: 'Gagal menghapus tagihan',
          message: e.toString(),
          actionLabel: 'Oke',
        );
      }
    }
  }

  Future<void> _markBillPaid(
    BuildContext context,
    WidgetRef ref,
    BillEntity bill,
  ) async {
    try {
      await ref.read(
        updateBillStatusProvider((bill.id, BillStatus.paid)).future,
      );

      // Invalidate providers so the UI refreshes with the updated status
      ref.invalidate(billsProvider);
      ref.invalidate(upcomingBillsProvider);
      ref.invalidate(billByIdProvider(bill.id));

      final localDatasource = await ref.read(
        billLocalDatasourceProvider.future,
      );
      final billModel = await localDatasource.getBillById(bill.id);
      if (billModel?.isarId != null) {
        await NotificationService().cancelBillReminder(billModel!.isarId!);
      }

      if (context.mounted) {
        await FeedbackDialog.showSuccess<void>(
          context,
          title: 'Tagihan ditandai lunas',
          message: 'Status tagihan sudah diperbarui.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        await FeedbackDialog.showError<void>(
          context,
          title: 'Gagal mengubah status',
          message: e.toString(),
          actionLabel: 'Oke',
        );
      }
    }
  }

  String _statusLabel(BillStatus status) {
    return switch (status) {
      BillStatus.paid => 'Lunas',
      BillStatus.overdue => 'Terlewat',
      BillStatus.pending => 'Mendekati',
      BillStatus.upcoming => 'Akan Datang',
    };
  }

  IconData _statusIcon(BillStatus status) {
    return switch (status) {
      BillStatus.paid => Icons.check_circle,
      BillStatus.overdue => Icons.error,
      BillStatus.pending => Icons.warning,
      BillStatus.upcoming => Icons.receipt_long,
    };
  }

  Color _statusColor(BillStatus status) {
    return switch (status) {
      BillStatus.paid => AppColors.successColor,
      BillStatus.overdue => AppColors.dangerColor,
      BillStatus.pending => AppColors.warningDark,
      BillStatus.upcoming => AppColors.primaryColor,
    };
  }

  String _reminderLabel(BillEntity bill) {
    if (bill.waktuPengingat == bill.tanggalJatuhTempo) {
      return 'Hari H';
    }

    final diff = bill.tanggalJatuhTempo.difference(bill.waktuPengingat).inDays;
    if (diff > 0) {
      return 'H-$diff (${DateFormatter.formatDate(bill.waktuPengingat)})';
    }

    return DateFormatter.formatDate(bill.waktuPengingat);
  }
}
