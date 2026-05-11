import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';
import 'package:sisasaku/routes/app_router.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  final List<_BudgetItem> _dummyBudgets = const [
    _BudgetItem(
      category: 'Makan',
      icon: Icons.restaurant,
      iconColor: AppColors.warningColor,
      spent: 1200000,
      limit: 2000000,
    ),
    _BudgetItem(
      category: 'Transportasi',
      icon: Icons.directions_bus,
      iconColor: AppColors.textSecondary,
      spent: 450000,
      limit: 500000,
    ),
    _BudgetItem(
      category: 'Belanja',
      icon: Icons.shopping_bag,
      iconColor: AppColors.tertiary,
      spent: 1800000,
      limit: 1500000,
    ),
    _BudgetItem(
      category: 'Kos',
      icon: Icons.home_work,
      iconColor: AppColors.primaryColor,
      spent: 1500000,
      limit: 1500000,
    ),
    _BudgetItem(
      category: 'Jajan',
      icon: Icons.local_cafe,
      iconColor: AppColors.warningDark,
      spent: 300000,
      limit: 800000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalLimit = _dummyBudgets.fold<double>(0, (s, b) => s + b.limit);
    final totalSpent = _dummyBudgets.fold<double>(0, (s, b) => s + b.spent);
    final remaining = totalLimit - totalSpent;

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
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
                  color: AppColors.primaryLight.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
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
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSummaryCard(totalLimit, totalSpent, remaining),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Detail Anggaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ..._dummyBudgets.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _buildBudgetItem(item),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.addBudget),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Anggaran',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textSecondary,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.bgPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const Text(
          'Anggaran Bulan Ini',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(double limit, double spent, double remaining) {
    final isOver = remaining < 0;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
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
                  color: AppColors.textPrimary,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.borderColor),
              Expanded(
                child: _SummaryColumn(
                  label: 'Terpakai',
                  amount: spent,
                  color: AppColors.tertiary,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.borderColor),
              Expanded(
                child: _SummaryColumn(
                  label: 'Sisa',
                  amount: remaining.abs(),
                  color: isOver ? AppColors.dangerColor : AppColors.successColor,
                  prefix: isOver ? '-' : '',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: (spent / limit).clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.bgTertiary,
              valueColor: AlwaysStoppedAnimation(
                isOver ? AppColors.dangerColor : AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(_BudgetItem item) {
    final progress = item.limit > 0 ? (item.spent / item.limit).clamp(0.0, 1.0) : 0.0;
    final isOver = item.spent > item.limit;
    final progressColor = isOver ? AppColors.dangerColor : AppColors.primaryColor;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
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
                  color: item.iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${CurrencyFormatter.format(item.spent)} / ${CurrencyFormatter.format(item.limit)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
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
              backgroundColor: AppColors.bgTertiary,
              valueColor: AlwaysStoppedAnimation(progressColor),
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
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
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

class _BudgetItem {
  final String category;
  final IconData icon;
  final Color iconColor;
  final double spent;
  final double limit;

  const _BudgetItem({
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.spent,
    required this.limit,
  });
}
