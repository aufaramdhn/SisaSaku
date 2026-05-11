import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';
import 'package:sisasaku/routes/app_router.dart';

class DebtPage extends StatefulWidget {
  const DebtPage({super.key});

  @override
  State<DebtPage> createState() => _DebtPageState();
}

class _DebtPageState extends State<DebtPage> {
  String _filter = 'i_owe';

  final _dummyDebts = const [
    _DebtItem(
      id: '1',
      person: 'Andi Pratama',
      amount: 250000,
      date: '10 Okt 2023',
      notes: 'Pinjam buat beli headset',
      isIOwe: true,
      isSettled: false,
    ),
    _DebtItem(
      id: '2',
      person: 'Budi Santoso',
      amount: 100000,
      date: '5 Okt 2023',
      notes: 'Pinjam uang transport',
      isIOwe: true,
      isSettled: true,
    ),
    _DebtItem(
      id: '3',
      person: 'Citra Lestari',
      amount: 500000,
      date: '12 Okt 2023',
      notes: 'Citra pinjam buat kos',
      isIOwe: false,
      isSettled: false,
    ),
    _DebtItem(
      id: '4',
      person: 'Dewi Kusuma',
      amount: 150000,
      date: '1 Okt 2023',
      notes: 'Pinjam buat beli buku',
      isIOwe: false,
      isSettled: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _dummyDebts.where((d) {
      if (_filter == 'i_owe') return d.isIOwe;
      return !d.isIOwe;
    }).toList();

    final totalUnpaid = filtered
        .where((d) => !d.isSettled)
        .fold<double>(0, (s, d) => s + d.amount);

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
          Positioned(
            bottom: -40,
            right: -40,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.dangerColor.withValues(alpha: 0.06),
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
                  _buildSummaryCard(totalUnpaid),
                  const SizedBox(height: AppSpacing.lg),
                  _buildToggleTabs(),
                  const SizedBox(height: AppSpacing.lg),
                  if (filtered.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl2),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppColors.textSecondary,
                              size: 48,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _filter == 'i_owe'
                                  ? 'Belum ada hutang'
                                  : 'Belum ada piutang',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...filtered.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _buildDebtCard(item),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.addDebt),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah',
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
          'Hutang & Piutang',
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

  Widget _buildSummaryCard(double totalUnpaid) {
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
          Text(
            _filter == 'i_owe'
                ? 'Total Hutang Belum Lunas'
                : 'Total Piutang Belum Lunas',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
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
              height: 1.2,
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
        color: AppColors.bgTertiary,
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
      color: isActive ? AppColors.bgPrimary : Colors.transparent,
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
              color: isActive ? AppColors.primaryColor : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDebtCard(_DebtItem item) {
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
        border: Border(
          left: BorderSide(
            color: item.isSettled
                ? AppColors.successColor
                : (item.isIOwe ? AppColors.dangerColor : AppColors.warningDark),
            width: 3,
          ),
        ),
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
                  color: item.isSettled
                      ? AppColors.successLight
                      : AppColors.bgSecondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isIOwe ? Icons.arrow_upward : Icons.arrow_downward,
                  color: item.isSettled
                      ? AppColors.successColor
                      : (item.isIOwe ? AppColors.dangerColor : AppColors.warningDark),
                  size: 20,
                ),
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
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: item.isSettled ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.date,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.isSettled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Text(
                    'Lunas',
                    style: TextStyle(
                      color: AppColors.successColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.isIOwe
                        ? AppColors.dangerLight
                        : AppColors.warningLight,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    item.isIOwe ? 'Belum Bayar' : 'Menunggu',
                    style: TextStyle(
                      color: item.isIOwe
                          ? AppColors.dangerColor
                          : AppColors.warningDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.notes,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                CurrencyFormatter.format(item.amount),
                style: TextStyle(
                  color: item.isSettled
                      ? AppColors.textSecondary
                      : (item.isIOwe ? AppColors.dangerColor : AppColors.warningDark),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  decoration: item.isSettled ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DebtItem {
  final String id;
  final String person;
  final double amount;
  final String date;
  final String notes;
  final bool isIOwe;
  final bool isSettled;

  const _DebtItem({
    required this.id,
    required this.person,
    required this.amount,
    required this.date,
    required this.notes,
    required this.isIOwe,
    required this.isSettled,
  });
}
