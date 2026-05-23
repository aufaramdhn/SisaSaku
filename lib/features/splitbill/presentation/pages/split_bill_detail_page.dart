import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';
import 'package:sisasaku/features/splitbill/domain/entities/split_bill_entity.dart';
import 'package:sisasaku/features/splitbill/presentation/providers/split_bill_provider.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';

class SplitBillDetailPage extends ConsumerWidget {
  final String splitBillId;

  const SplitBillDetailPage({super.key, required this.splitBillId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splitBillAsync = ref.watch(splitBillByIdProvider(splitBillId));

    return Scaffold(
      backgroundColor: AppColors.bgSecondaryOf(context),
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
            child: splitBillAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Gagal memuat detail: $err')),
              data: (splitBill) {
                if (splitBill == null) {
                  return const Center(
                    child: Text('Data bagi rata tidak ditemukan'),
                  );
                }
                return _DetailContent(splitBill: splitBill);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  final SplitBillEntity splitBill;

  const _DetailContent({required this.splitBill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paidCount = splitBill.paidParticipantNames.length;
    final progress = splitBill.participantNames.isEmpty
        ? 0.0
        : paidCount / splitBill.participantNames.length;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref),
                const SizedBox(height: AppSpacing.xl),
                _buildNominalBlock(context),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.bgPrimaryOf(context),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.groups,
                            color: AppColors.primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Peserta',
                              style: TextStyle(
                                color: AppColors.textPrimaryOf(context),
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            '$paidCount/${splitBill.participantNames.length}',
                            style: TextStyle(
                              color: AppColors.textSecondaryOf(context),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: AppColors.bgTertiaryOf(context),
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...List.generate(splitBill.participantNames.length, (
                        index,
                      ) {
                        final name = splitBill.participantNames[index];
                        final amount =
                            index < splitBill.participantAmounts.length
                            ? splitBill.participantAmounts[index]
                            : 0.0;
                        final isPaid = splitBill.paidParticipantNames.contains(
                          name,
                        );
                        return _buildParticipantRow(
                          context,
                          ref,
                          name,
                          amount,
                          isPaid,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildTotalCollected(context),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () async {
                  for (final name in splitBill.participantNames) {
                    await ref.read(
                      markParticipantPaidProvider((
                        splitBill.id,
                        name,
                        true,
                      )).future,
                    );
                  }
                  if (context.mounted) context.pop();
                },
                child: const Text('Tandai Semua Lunas'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: AppColors.textSecondaryOf(context)),
          style: IconButton.styleFrom(backgroundColor: AppColors.bgPrimaryOf(context)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'Detail Bagi Rata',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
        ),
        IconButton(
          onPressed: () async {
            final confirmed = await FeedbackDialog.showConfirm(
              context,
              title: 'Hapus Bagi Rata',
              message: 'Data bagi rata ini akan dihapus. Lanjutkan?',
              actionLabel: 'Hapus',
            );
            if (!context.mounted || !confirmed) return;
            await ref.read(deleteSplitBillProvider(splitBill.id).future);
            if (context.mounted) context.pop();
          },
          icon: const Icon(Icons.delete_outline, color: AppColors.dangerColor),
          style: IconButton.styleFrom(backgroundColor: AppColors.dangerLight),
        ),
      ],
    );
  }

  Widget _buildNominalBlock(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgPrimaryOf(context),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            splitBill.title,
            style: TextStyle(
              color: AppColors.textSecondaryOf(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CurrencyFormatter.format(splitBill.total),
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantRow(
    BuildContext context,
    WidgetRef ref,
    String name,
    double amount,
    bool isPaid,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(
          markParticipantPaidProvider((splitBill.id, name, !isPaid)).future,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(
                isPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isPaid
                    ? AppColors.successColor
                    : AppColors.textSecondaryOf(context),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: isPaid
                            ? AppColors.textSecondaryOf(context)
                            : AppColors.textPrimaryOf(context),
                        fontWeight: FontWeight.w600,
                        decoration: isPaid ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(amount),
                      style: TextStyle(
                        color: isPaid
                            ? AppColors.textSecondaryOf(context)
                            : AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: isPaid,
                onChanged: (value) => ref.read(
                  markParticipantPaidProvider((
                    splitBill.id,
                    name,
                    value ?? false,
                  )).future,
                ),
                activeColor: AppColors.successColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCollected(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgPrimaryOf(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Terkumpul',
            style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 14),
          ),
          Text(
            CurrencyFormatter.format(splitBill.paidTotal),
            style: TextStyle(
              color: AppColors.textPrimaryOf(context),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
