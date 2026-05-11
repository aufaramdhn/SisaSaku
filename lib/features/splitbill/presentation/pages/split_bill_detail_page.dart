import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';

class SplitBillDetailPage extends StatefulWidget {
  final String splitBillId;

  const SplitBillDetailPage({super.key, required this.splitBillId});

  @override
  State<SplitBillDetailPage> createState() => _SplitBillDetailPageState();
}

class _SplitBillDetailPageState extends State<SplitBillDetailPage> {
  final _dummyParticipants = [
    _Participant(name: 'Andi', amount: 50000, isPaid: true),
    _Participant(name: 'Budi', amount: 50000, isPaid: false),
    _Participant(name: 'Citra', amount: 50000, isPaid: true),
    _Participant(name: 'Dewi', amount: 50000, isPaid: false),
  ];

  final double _total = 200000;
  final String _title = 'Makan Bareng Warung Pak Kumis';

  @override
  Widget build(BuildContext context) {
    final paidCount = _dummyParticipants.where((p) => p.isPaid).length;
    final totalPaid = _dummyParticipants
        .where((p) => p.isPaid)
        .fold<double>(0, (s, p) => s + p.amount);

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
                  _buildNominalBlock(),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
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
                            const Icon(
                              Icons.groups,
                              color: AppColors.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Expanded(
                              child: Text(
                                'Peserta',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              '$paidCount/${_dummyParticipants.length}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
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
                            value: _dummyParticipants.isNotEmpty
                                ? paidCount / _dummyParticipants.length
                                : 0,
                            minHeight: 8,
                            backgroundColor: AppColors.bgTertiary,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ..._dummyParticipants.map((p) {
                          return _buildParticipantRow(p);
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Terkumpul',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(totalPaid),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            MediaQuery.of(context).padding.bottom + AppSpacing.md,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: Material(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: InkWell(
                onTap: () => context.pop(),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Tandai Selesai',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
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
        const Expanded(
          child: Text(
            'Detail Bagi Rata',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.delete_outline,
            color: AppColors.dangerColor,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.dangerLight,
          ),
        ),
      ],
    );
  }

  Widget _buildNominalBlock() {
    return Container(
      width: double.infinity,
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
            _title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Rp',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                CurrencyFormatter.format(_total).replaceFirst('Rp', ''),
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantRow(_Participant p) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            p.isPaid = !p.isPaid;
          });
        },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: p.isPaid
                      ? AppColors.successLight
                      : AppColors.bgSecondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  p.isPaid ? Icons.check : Icons.person_outline,
                  color: p.isPaid
                      ? AppColors.successColor
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: TextStyle(
                        color: p.isPaid
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: p.isPaid ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(p.amount),
                      style: TextStyle(
                        color: p.isPaid
                            ? AppColors.textSecondary
                            : AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        decoration: p.isPaid ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: p.isPaid,
                onChanged: (v) {
                  setState(() {
                    p.isPaid = v ?? false;
                  });
                },
                activeColor: AppColors.successColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Participant {
  String name;
  double amount;
  bool isPaid;

  _Participant({
    required this.name,
    required this.amount,
    required this.isPaid,
  });
}
