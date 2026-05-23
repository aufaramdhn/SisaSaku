import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/core/theme/app_color_extension.dart';
import 'package:sisasaku/core/utils/category_ui_helpers.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';
import 'package:sisasaku/features/budget/domain/entities/budget_entity.dart';
import 'package:sisasaku/features/budget/presentation/providers/budget_provider.dart';
import 'package:sisasaku/features/category/presentation/providers/category_provider.dart';
import 'package:sisasaku/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';

class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final budgetsAsync = ref.watch(budgetsProvider);
    final transactionsAsync = ref.watch(
      monthlyTransactionsProvider((now.month, now.year)),
    );
    final categoriesAsync = ref.watch(categoriesProvider);

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
            child: budgetsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Gagal memuat anggaran: $err')),
              data: (budgets) {
                final transactions = transactionsAsync.value ?? [];
                final categories = categoriesAsync.value ?? [];
                final categoryMap = {for (final c in categories) c.id: c};
                final visibleBudgets = budgets
                    .where((b) => b.month == now.month && b.year == now.year)
                    .toList();
                final spentByCategory = <String, double>{};
                for (final tx in transactions.where(
                  (t) => t.jenis == TransactionType.expense,
                )) {
                  spentByCategory.update(
                    tx.idKategori,
                    (value) => value + tx.nominal,
                    ifAbsent: () => tx.nominal,
                  );
                }
                final totalLimit = visibleBudgets.fold<double>(
                  0,
                  (s, b) => s + b.limit,
                );
                final totalSpent = visibleBudgets.fold<double>(
                  0,
                  (s, b) => s + (spentByCategory[b.idKategori] ?? 0),
                );
                final remaining = totalLimit - totalSpent;

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
                        title: 'Anggaran Bulan Ini',
                        showBackButton: true,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSummaryCard(context, totalLimit, totalSpent, remaining),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Detail Anggaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (visibleBudgets.isEmpty)
                        _buildEmptyState(context)
                      else
                        ...visibleBudgets.map((budget) {
                          final category = categoryMap[budget.idKategori];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: Dismissible(
                              key: ValueKey(budget.id),
                              direction: DismissDirection.endToStart,
                              background: _deleteBackground(),
                              confirmDismiss: (_) => FeedbackDialog.showConfirm(
                                context,
                                title: 'Hapus Anggaran',
                                message:
                                    'Anggaran ${budget.namaKategori} akan dihapus.',
                                actionLabel: 'Hapus',
                              ),
                              onDismissed: (_) {
                                ref.read(
                                  deleteBudgetProvider(budget.id).future,
                                );
                              },
                              child: _buildBudgetItem(
                                context,
                                budget,
                                spentByCategory[budget.idKategori] ?? 0,
                                CategoryUiHelpers.parseIcon(category?.ikon),
                                CategoryUiHelpers.parseColor(category?.warna),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
          Icon(
            Icons.pie_chart_outline,
            color: context.colors.textSecondary,
            size: 42,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Belum ada anggaran bulan ini',
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

  Widget _buildSummaryCard(BuildContext context, double limit, double spent, double remaining) {
    final isOver = remaining < 0;
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryColumn(
                  label: 'Total Anggaran',
                  amount: limit,
                  color: context.colors.textPrimary,
                ),
              ),
              Container(width: 1, height: 40, color: context.colors.borderColor),
              Expanded(
                child: _SummaryColumn(
                  label: 'Terpakai',
                  amount: spent,
                  color: AppColors.tertiary,
                ),
              ),
              Container(width: 1, height: 40, color: context.colors.borderColor),
              Expanded(
                child: _SummaryColumn(
                  label: 'Sisa',
                  amount: remaining.abs(),
                  color: isOver
                      ? AppColors.dangerColor
                      : AppColors.successColor,
                  prefix: isOver ? '-' : '',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: limit == 0 ? 0 : (spent / limit).clamp(0, 1),
              minHeight: 8,
              backgroundColor: context.colors.bgTertiary,
              valueColor: AlwaysStoppedAnimation(
                isOver ? AppColors.dangerColor : AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(
    BuildContext context,
    BudgetEntity budget,
    double spent,
    IconData icon,
    Color iconColor,
  ) {
    final progress = budget.limit > 0
        ? (spent / budget.limit).clamp(0.0, 1.0)
        : 0.0;
    final isOver = spent > budget.limit;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      budget.namaKategori,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${CurrencyFormatter.format(spent)} / ${CurrencyFormatter.format(budget.limit)}',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOver)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Text(
                    'Over',
                    style: TextStyle(
                      color: AppColors.dangerColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: context.colors.bgTertiary,
              valueColor: AlwaysStoppedAnimation(
                isOver ? AppColors.dangerColor : AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final String prefix;

  const _SummaryColumn({
    required this.label,
    required this.amount,
    required this.color,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          '$prefix${CurrencyFormatter.format(amount)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
