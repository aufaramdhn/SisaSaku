import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/theme/app_color_extension.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';
import 'package:sisasaku/features/splitbill/domain/entities/split_bill_entity.dart';
import 'package:sisasaku/features/splitbill/presentation/providers/split_bill_provider.dart';
import 'package:sisasaku/routes/app_router.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';

class SplitBillPage extends ConsumerWidget {
  const SplitBillPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splitBillsAsync = ref.watch(splitBillsProvider);

    return Scaffold(
      backgroundColor: context.colors.bgSecondary,
      body: Stack(
        children: [
          Positioned(
            top: -40,
            left: -40,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 240,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.decorativeBlurOf(context, alpha: 0.4),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: splitBillsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Gagal memuat bagi rata: $err')),
              data: (items) {
                final totalUnpaid = items
                    .where((i) => !i.isSettled)
                    .fold<double>(0, (s, i) => s + i.myShare);

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppPageHeader(
                        title: 'Bagi Rata',
                        showBackButton: true,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSummaryCard(context, totalUnpaid, items.length),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Daftar Bagi Rata',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (items.isEmpty)
                        _buildEmptyState(context)
                      else
                        ...items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: Dismissible(
                              key: ValueKey(item.id),
                              direction: DismissDirection.endToStart,
                              background: _deleteBackground(),
                              confirmDismiss: (_) => FeedbackDialog.showConfirm(
                                context,
                                title: 'Hapus Bagi Rata',
                                message: '${item.title} akan dihapus.',
                                actionLabel: 'Hapus',
                              ),
                              onDismissed: (_) => ref.read(
                                deleteSplitBillProvider(item.id).future,
                              ),
                              child: _buildBillCard(context, item),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AppModernFab(
        onPressed: () => context.push(AppRouter.addSplitBill),
        icon: Icons.add,
        label: 'Tambah Bagi Rata',
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.colors.bgPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Icon(Icons.groups_outlined, color: context.colors.textSecondary, size: 42),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Belum ada bagi rata',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.dangerColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }

  Widget _buildSummaryCard(BuildContext context, double totalUnpaid, int totalItems) {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum Dibayar',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  CurrencyFormatter.format(totalUnpaid),
                  style: const TextStyle(
                    color: AppColors.dangerColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: context.colors.borderColor),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$totalItems',
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(BuildContext context, SplitBillEntity item) {
    final progress = item.participantNames.isEmpty
        ? 0.0
        : item.paidParticipantNames.length / item.participantNames.length;

    return Material(
      color: context.colors.bgPrimary,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: () =>
            context.push(AppRouter.splitBillDetail.replaceAll(':id', item.id)),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _StatusPill(isSettled: item.isSettled),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${CurrencyFormatter.format(item.total)} · ${item.participantNames.length} orang',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: context.colors.bgTertiary,
                  valueColor: AlwaysStoppedAnimation(
                    item.isSettled
                        ? AppColors.successColor
                        : AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${item.paidParticipantNames.length}/${item.participantNames.length} lunas · Bagian saya: ${CurrencyFormatter.format(item.myShare)}',
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isSettled;

  const _StatusPill({required this.isSettled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isSettled ? AppColors.successLight : AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        isSettled ? 'Selesai' : 'Belum',
        style: TextStyle(
          color: isSettled ? AppColors.successColor : AppColors.warningDark,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
