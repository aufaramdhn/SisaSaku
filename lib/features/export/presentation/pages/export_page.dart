import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  String _selectedFormat = 'pdf';
  final String _selectedMonth = 'Oktober 2023';

  final _previewData = const _PreviewData(
    pemasukan: 5400000,
    pengeluaran: 3250000,
    saldo: 2150000,
    totalTransaksi: 24,
  );

  @override
  Widget build(BuildContext context) {
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
                  _buildMonthSelector(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFormatSelector(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPreviewCard(),
                  const SizedBox(height: AppSpacing.lg),
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
                onTap: () {},
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedFormat == 'pdf'
                            ? Icons.picture_as_pdf_outlined
                            : Icons.description_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Ekspor ${_selectedFormat.toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
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
        const Text(
          'Ekspor Data',
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

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
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
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            _selectedMonth,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Format File',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildFormatCard(
                label: 'PDF',
                icon: Icons.picture_as_pdf_outlined,
                isSelected: _selectedFormat == 'pdf',
                onTap: () => setState(() => _selectedFormat = 'pdf'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildFormatCard(
                label: 'CSV',
                icon: Icons.description_outlined,
                isSelected: _selectedFormat == 'csv',
                onTap: () => setState(() => _selectedFormat = 'csv'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColors.primaryLight : AppColors.bgPrimary,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
                size: 32,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
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
          const Text(
            'Pratinjau',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildPreviewRow('Periode', _selectedMonth),
          const Divider(height: 24, color: AppColors.borderColor),
          _buildPreviewRow(
            'Total Transaksi',
            '${_previewData.totalTransaksi}',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPreviewRow(
            'Pemasukan',
            CurrencyFormatter.format(_previewData.pemasukan),
            valueColor: AppColors.successColor,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPreviewRow(
            'Pengeluaran',
            CurrencyFormatter.format(_previewData.pengeluaran),
            valueColor: AppColors.tertiary,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPreviewRow(
            'Saldo',
            CurrencyFormatter.format(_previewData.saldo),
            valueColor: AppColors.primaryColor,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _PreviewData {
  final double pemasukan;
  final double pengeluaran;
  final double saldo;
  final int totalTransaksi;

  const _PreviewData({
    required this.pemasukan,
    required this.pengeluaran,
    required this.saldo,
    required this.totalTransaksi,
  });
}
