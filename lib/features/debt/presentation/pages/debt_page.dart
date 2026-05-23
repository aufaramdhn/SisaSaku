import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/theme/app_color_extension.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';
import 'package:sisasaku/features/debt/domain/entities/debt_entity.dart';
import 'package:sisasaku/features/debt/presentation/providers/debt_provider.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';

class DebtPage extends ConsumerStatefulWidget {
  const DebtPage({super.key});

  @override
  ConsumerState<DebtPage> createState() => _DebtPageState();
}

class _DebtPageState extends ConsumerState<DebtPage> {
  String _filter = 'i_owe';
  final Set<String> _settlingIds = {};

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(debtsProvider);

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
            child: debtsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Gagal memuat data: $err')),
              data: (debts) {
                final filtered = debts.where((d) => d.type == _filter).toList();
                final totalUnpaid = filtered
                    .where((d) => !d.isSettled)
                    .fold<double>(0, (s, d) => s + d.amount);

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
                        title: 'Hutang & Piutang',
                        showBackButton: true,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSummaryCard(totalUnpaid),
                      const SizedBox(height: AppSpacing.lg),
                      _buildToggleTabs(),
                      const SizedBox(height: AppSpacing.lg),
                      if (filtered.isEmpty)
                        _buildEmptyState()
                      else
                        ...filtered.map(
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
                                title: 'Hapus Data',
                                message: 'Data ${item.person} akan dihapus.',
                                actionLabel: 'Hapus',
                              ),
                              onDismissed: (_) =>
                                  ref.read(deleteDebtProvider(item.id).future),
                              child: _buildDebtCard(item),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: context.colors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _filter == 'i_owe' ? 'Belum ada hutang' : 'Belum ada piutang',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
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

  Widget _buildSummaryCard(double totalUnpaid) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.bgPrimary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
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
            _filter == 'i_owe'
                ? 'Total Hutang Belum Lunas'
                : 'Total Piutang Belum Lunas',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CurrencyFormatter.format(totalUnpaid),
            style: TextStyle(
              color: _filter == 'i_owe'
                  ? AppColors.dangerColor
                  : AppColors.warningDark,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.bgTertiary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'Saya Hutang',
              isActive: _filter == 'i_owe',
              onTap: () => setState(() => _filter = 'i_owe'),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: 'Hutang ke Saya',
              isActive: _filter == 'they_owe',
              onTap: () => setState(() => _filter = 'they_owe'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? context.colors.bgPrimary : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      elevation: isActive ? 1 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? AppColors.primaryColor
                  : context.colors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleSettlement(DebtEntity item) async {
    if (_settlingIds.contains(item.id)) return;

    setState(() => _settlingIds.add(item.id));
    try {
      await ref.read(
        updateDebtSettlementProvider((item.id, !item.isSettled)).future,
      );
    } finally {
      if (mounted) {
        setState(() => _settlingIds.remove(item.id));
      }
    }
  }

  Widget _buildDebtCard(DebtEntity item) {
    final isSettling = _settlingIds.contains(item.id);

    return Material(
      color: context.colors.bgPrimary,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: () => _toggleSettlement(item),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border(
              left: BorderSide(
                color: item.isSettled
                    ? AppColors.successColor
                    : (item.type == 'i_owe'
                          ? AppColors.dangerColor
                          : AppColors.warningDark),
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              if (isSettling)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  item.type == 'i_owe'
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: item.isSettled
                      ? AppColors.successColor
                      : (item.type == 'i_owe'
                            ? AppColors.dangerColor
                            : AppColors.warningDark),
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.person,
                      style: TextStyle(
                        color: item.isSettled
                            ? context.colors.textSecondary
                            : context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        decoration: item.isSettled
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.notes?.isNotEmpty == true
                          ? item.notes!
                          : _formatDate(item.date),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(item.amount),
                    style: TextStyle(
                      color: item.isSettled
                          ? context.colors.textSecondary
                          : context.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isSettling)
                    Text(
                      'Memproses...',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Text(
                      item.isSettled ? 'Lunas' : 'Tap untuk lunas',
                      style: TextStyle(
                        color: item.isSettled
                            ? AppColors.successColor
                            : context.colors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
