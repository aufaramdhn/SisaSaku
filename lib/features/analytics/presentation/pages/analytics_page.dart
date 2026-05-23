import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/constants/app_strings.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/core/utils/category_ui_helpers.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';
import 'package:sisasaku/features/category/domain/entities/category_entity.dart';
import 'package:sisasaku/features/category/presentation/providers/category_provider.dart';
import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';
import 'package:sisasaku/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:sisasaku/routes/app_router.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  String _period = 'bulan';

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondaryOf(context),
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -60,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warningColor.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Gagal memuat analitik: $err')),
              data: (transactions) {
                final categories = categoriesAsync.valueOrNull ?? const [];
                final analytics = _buildAnalyticsSnapshot(
                  transactions,
                  categories,
                );
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
                      _buildHeader(context),
                      const SizedBox(height: AppSpacing.xl),
                      _buildPeriodSelector(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSummaryCards(analytics),
                      const SizedBox(height: AppSpacing.xl),
                      _buildBarChart(analytics),
                      const SizedBox(height: AppSpacing.xl),
                      _buildCategoryBreakdown(analytics),
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

  Widget _buildHeader(BuildContext context) {
    return AppPageHeader(
      title: AppStrings.analitik,
      trailing: AppHeaderIconButton(
        icon: Icons.download_outlined,
        color: AppColors.primaryColor,
        onPressed: () => context.push(AppRouter.exportData),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = [
      ('Minggu', 'minggu'),
      ('Bulan', 'bulan'),
      ('Tahun', 'tahun'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgTertiaryOf(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: periods.map((p) {
          final isActive = _period == p.$2;
          return Expanded(
            child: Material(
              color: isActive ? AppColors.bgPrimaryOf(context) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
              elevation: isActive ? 1 : 0,
              child: InkWell(
                onTap: () => setState(() => _period = p.$2),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  child: Text(
                    p.$1,
                    style: TextStyle(
                      color: isActive
                          ? AppColors.primaryColor
                          : AppColors.textSecondaryOf(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(_AnalyticsSnapshot analytics) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.arrow_downward_rounded,
            iconBgColor: AppColors.successLight,
            iconColor: AppColors.successColor,
            badgeText: _formatChangeBadge(
              analytics.income,
              analytics.previousIncome,
            ),
            badgeBgColor: AppColors.successLight,
            badgeTextColor: AppColors.successColor,
            label: AppStrings.pemasukan,
            value: CurrencyFormatter.format(analytics.income),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SummaryCard(
            icon: Icons.arrow_upward_rounded,
            iconBgColor: AppColors.dangerLight,
            iconColor: AppColors.dangerColor,
            badgeText: _formatChangeBadge(
              analytics.expense,
              analytics.previousExpense,
            ),
            badgeBgColor: AppColors.dangerLight,
            badgeTextColor: AppColors.dangerColor,
            label: AppStrings.pengeluaran,
            value: CurrencyFormatter.format(analytics.expense),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(_AnalyticsSnapshot analytics) {
    final maxAmount = analytics.bars.isEmpty
        ? 1.0
        : analytics.bars
              .map((bar) => bar.amount)
              .fold<double>(0, (max, value) => math.max(max, value))
              .clamp(1, double.infinity);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPrimaryOf(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderColorOf(context).withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                analytics.barTitle,
                style: TextStyle(
                  color: AppColors.textPrimaryOf(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.3,
                ),
              ),
              Text(
                analytics.rangeLabel,
                style: TextStyle(
                  color: AppColors.textSecondaryOf(context),
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (analytics.bars.every((bar) => bar.amount == 0))
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                'Belum ada pengeluaran pada periode ini.',
                style: TextStyle(color: AppColors.textSecondaryOf(context)),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: analytics.bars.map((bar) {
                  final ratio = bar.amount <= 0 ? 0.04 : bar.amount / maxAmount;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (bar.isPeak)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.xs,
                              ),
                              child: Text(
                                _formatCompactCurrency(bar.amount),
                                style: TextStyle(
                                  color: AppColors.textSecondaryOf(context),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          Container(
                            width: double.infinity,
                            height: 120 * ratio,
                            decoration: BoxDecoration(
                              color: bar.isPeak
                                  ? AppColors.warningColor
                                  : AppColors.primaryLight,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            bar.label,
                            style: TextStyle(
                              color: bar.isPeak
                                  ? AppColors.textPrimaryOf(context)
                                  : AppColors.textSecondaryOf(context),
                              fontWeight: bar.isPeak
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              fontSize: 9,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(_AnalyticsSnapshot analytics) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPrimaryOf(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderColorOf(context).withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rincian Kategori',
            style: TextStyle(
              color: AppColors.textPrimaryOf(context),
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (analytics.categories.isEmpty)
            Text(
              'Belum ada pengeluaran berkategori pada periode ini.',
              style: TextStyle(color: AppColors.textSecondaryOf(context)),
            )
          else
            ...analytics.categories.map((cat) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(cat.icon, color: cat.color, size: 16),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              cat.name,
                              style: TextStyle(
                                color: AppColors.textPrimaryOf(context),
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          CurrencyFormatter.format(cat.amount),
                          style: TextStyle(
                            color: AppColors.textPrimaryOf(context),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(
                        value: cat.share,
                        backgroundColor: AppColors.bgTertiaryOf(context),
                        valueColor: AlwaysStoppedAnimation(cat.color),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(cat.share * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: AppColors.textSecondaryOf(context),
                          fontWeight: FontWeight.w400,
                          fontSize: 9,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  _AnalyticsSnapshot _buildAnalyticsSnapshot(
    List<TransactionEntity> transactions,
    List<CategoryEntity> categories,
  ) {
    final now = DateTime.now();
    final current = _filterTransactions(transactions, now, _period);
    final previous = _filterTransactions(
      transactions,
      _previousReference(now, _period),
      _period,
    );
    final currentExpense = current
        .where((item) => item.jenis == TransactionType.expense)
        .toList();
    final categoryMap = {
      for (final category in categories) category.id: category,
    };

    return _AnalyticsSnapshot(
      income: _sumByType(current, TransactionType.income),
      expense: _sumByType(current, TransactionType.expense),
      previousIncome: _sumByType(previous, TransactionType.income),
      previousExpense: _sumByType(previous, TransactionType.expense),
      bars: _buildBars(currentExpense, now),
      categories: _buildCategorySpending(currentExpense, categoryMap),
      barTitle: switch (_period) {
        'minggu' => 'Pengeluaran Harian',
        'tahun' => 'Pengeluaran Bulanan',
        _ => 'Pengeluaran Mingguan',
      },
      rangeLabel: switch (_period) {
        'minggu' => '7 hari terakhir',
        'tahun' => 'Tahun ini',
        _ => 'Bulan ini',
      },
    );
  }

  List<TransactionEntity> _filterTransactions(
    List<TransactionEntity> transactions,
    DateTime reference,
    String period,
  ) {
    final start = switch (period) {
      'minggu' => DateTime(
        reference.year,
        reference.month,
        reference.day,
      ).subtract(const Duration(days: 6)),
      'tahun' => DateTime(reference.year, 1, 1),
      _ => DateTime(reference.year, reference.month, 1),
    };
    final end = switch (period) {
      'minggu' => DateTime(
        reference.year,
        reference.month,
        reference.day,
        23,
        59,
        59,
      ),
      'tahun' => DateTime(reference.year, 12, 31, 23, 59, 59),
      _ => DateTime(reference.year, reference.month + 1, 0, 23, 59, 59),
    };
    return transactions.where((item) {
      return !item.tanggal.isBefore(start) && !item.tanggal.isAfter(end);
    }).toList();
  }

  DateTime _previousReference(DateTime now, String period) {
    return switch (period) {
      'minggu' => now.subtract(const Duration(days: 7)),
      'tahun' => DateTime(now.year - 1, now.month, now.day),
      _ => DateTime(now.year, now.month - 1, now.day),
    };
  }

  double _sumByType(List<TransactionEntity> items, TransactionType type) {
    return items
        .where((item) => item.jenis == type)
        .fold<double>(0, (sum, item) => sum + item.nominal);
  }

  List<_BarDatum> _buildBars(List<TransactionEntity> expenses, DateTime now) {
    switch (_period) {
      case 'minggu':
        final result = <_BarDatum>[];
        for (var i = 6; i >= 0; i--) {
          final date = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(Duration(days: i));
          final total = expenses
              .where((item) => _isSameDay(item.tanggal, date))
              .fold<double>(0, (sum, item) => sum + item.nominal);
          result.add(
            _BarDatum(label: _weekdayLabel(date.weekday), amount: total),
          );
        }
        return _markPeak(result);
      case 'tahun':
        final labels = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agu',
          'Sep',
          'Okt',
          'Nov',
          'Des',
        ];
        final result = <_BarDatum>[];
        for (var month = 1; month <= 12; month++) {
          final total = expenses
              .where((item) => item.tanggal.month == month)
              .fold<double>(0, (sum, item) => sum + item.nominal);
          result.add(_BarDatum(label: labels[month - 1], amount: total));
        }
        return _markPeak(result);
      default:
        final result = <_BarDatum>[];
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        for (var weekIndex = 0; weekIndex < 5; weekIndex++) {
          final startDay = (weekIndex * 7) + 1;
          if (startDay > daysInMonth) break;
          final endDay = math.min(startDay + 6, daysInMonth);
          final total = expenses
              .where(
                (item) =>
                    item.tanggal.day >= startDay && item.tanggal.day <= endDay,
              )
              .fold<double>(0, (sum, item) => sum + item.nominal);
          result.add(_BarDatum(label: 'W${weekIndex + 1}', amount: total));
        }
        return _markPeak(result);
    }
  }

  List<_BarDatum> _markPeak(List<_BarDatum> bars) {
    if (bars.isEmpty) return bars;
    final maxAmount = bars
        .map((bar) => bar.amount)
        .fold<double>(0, (max, value) => math.max(max, value));
    return bars
        .map(
          (bar) => _BarDatum(
            label: bar.label,
            amount: bar.amount,
            isPeak: maxAmount > 0 && bar.amount == maxAmount,
          ),
        )
        .toList();
  }

  List<_CategorySpend> _buildCategorySpending(
    List<TransactionEntity> expenses,
    Map<String, CategoryEntity> categories,
  ) {
    final totalExpense = expenses.fold<double>(
      0,
      (sum, item) => sum + item.nominal,
    );
    if (totalExpense <= 0) return const [];

    final grouped = <String, double>{};
    for (final item in expenses) {
      grouped.update(
        item.idKategori,
        (value) => value + item.nominal,
        ifAbsent: () => item.nominal,
      );
    }

    final result = grouped.entries.map((entry) {
      final category = categories[entry.key];
      return _CategorySpend(
        name: category?.nama ?? 'Tanpa Kategori',
        icon: CategoryUiHelpers.parseIcon(category?.ikon),
        color: CategoryUiHelpers.parseColor(category?.warna),
        amount: entry.value,
        share: entry.value / totalExpense,
      );
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));

    return result.take(5).toList();
  }

  String _formatChangeBadge(double current, double previous) {
    if (previous <= 0) return current > 0 ? 'Baru' : '0%';
    final diff = ((current - previous) / previous) * 100;
    final sign = diff > 0 ? '+' : '';
    return '$sign${diff.toStringAsFixed(0)}%';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Sen',
      DateTime.tuesday => 'Sel',
      DateTime.wednesday => 'Rab',
      DateTime.thursday => 'Kam',
      DateTime.friday => 'Jum',
      DateTime.saturday => 'Sab',
      _ => 'Min',
    };
  }

  String _formatCompactCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    }
    if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}k';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }
}

class _AnalyticsSnapshot {
  final double income;
  final double expense;
  final double previousIncome;
  final double previousExpense;
  final List<_BarDatum> bars;
  final List<_CategorySpend> categories;
  final String barTitle;
  final String rangeLabel;

  const _AnalyticsSnapshot({
    required this.income,
    required this.expense,
    required this.previousIncome,
    required this.previousExpense,
    required this.bars,
    required this.categories,
    required this.barTitle,
    required this.rangeLabel,
  });
}

class _BarDatum {
  final String label;
  final double amount;
  final bool isPeak;

  const _BarDatum({
    required this.label,
    required this.amount,
    this.isPeak = false,
  });
}

class _CategorySpend {
  final String name;
  final IconData icon;
  final Color color;
  final double amount;
  final double share;

  const _CategorySpend({
    required this.name,
    required this.icon,
    required this.color,
    required this.amount,
    required this.share,
  });
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String badgeText;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final String label;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.badgeText,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPrimaryOf(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderColorOf(context).withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 9,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondaryOf(context),
              fontWeight: FontWeight.w400,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimaryOf(context),
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
