import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/core/utils/category_ui_helpers.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';
import 'package:sisasaku/features/category/domain/entities/category_entity.dart';
import 'package:sisasaku/features/category/presentation/providers/category_provider.dart';
import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';
import 'package:sisasaku/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:sisasaku/routes/app_router.dart';

class TransactionDetailPage extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(transactionByIdProvider(transactionId));
    final categoriesAsync = ref.watch(categoriesProvider);

    return transactionAsync.when(
      data: (transaction) {
        if (transaction == null) {
          return _buildMissingState(context);
        }

        final categories = categoriesAsync.maybeWhen(
          data: (list) => list,
          orElse: () => const <CategoryEntity>[],
        );
        final category = _findCategory(categories, transaction.idKategori);

        final isExpense = transaction.jenis == TransactionType.expense;
        final amountColor = isExpense
            ? AppColors.tertiary
            : AppColors.successColor;
        final categoryIcon = CategoryUiHelpers.parseIcon(
          category?.ikon ?? 'category',
        );
        final categoryColor = CategoryUiHelpers.parseColor(
          category?.warna ?? '#9CA3AF',
        );

        return Scaffold(
          backgroundColor: AppColors.bgSecondary,
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
                      color: amountColor.withValues(alpha: 0.08),
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
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.textSecondary,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.bgPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Detail Transaksi',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  context.push(
                                    AppRouter.editTransaction.replaceAll(
                                      ':id',
                                      transactionId,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.primaryColor,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.bgPrimary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              IconButton(
                                onPressed: () => _showDeleteDialog(
                                  context,
                                  ref,
                                  transaction,
                                ),
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
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              decoration: BoxDecoration(
                                color: AppColors.bgPrimary,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
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
                                    isExpense ? 'Pengeluaran' : 'Pemasukan',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    CurrencyFormatter.format(
                                      transaction.nominal,
                                    ),
                                    style: TextStyle(
                                      color: amountColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 36,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: AppColors.bgPrimary,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
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
                                    icon: categoryIcon,
                                    iconColor: categoryColor,
                                    label: 'Kategori',
                                    value: category?.nama ?? 'Tidak diketahui',
                                  ),
                                  const Divider(
                                    height: 32,
                                    color: AppColors.borderColor,
                                  ),
                                  _buildInfoRow(
                                    icon: Icons.calendar_today_outlined,
                                    iconColor: AppColors.primaryColor,
                                    label: 'Tanggal',
                                    value: _formatDate(transaction.tanggal),
                                  ),
                                  const Divider(
                                    height: 32,
                                    color: AppColors.borderColor,
                                  ),
                                  _buildInfoRow(
                                    icon: Icons.notes_outlined,
                                    iconColor: AppColors.textSecondary,
                                    label: 'Catatan',
                                    value:
                                        (transaction.deskripsi?.isNotEmpty ??
                                            false)
                                        ? transaction.deskripsi!
                                        : 'Tidak ada catatan',
                                  ),
                                ],
                              ),
                            ),
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
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.bgSecondary,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: AppColors.bgSecondary,
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final hari = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    final bulan = [
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
    return '${hari[date.weekday % 7]}, ${date.day} ${bulan[date.month - 1]} ${date.year}';
  }

  CategoryEntity? _findCategory(List<CategoryEntity> categories, String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  Widget _buildMissingState(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Transaksi tidak ditemukan'),
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

  Widget _buildInfoRow({
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
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
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

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    TransactionEntity transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text(
          'Hapus Transaksi',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Transaksi akan dihapus permanen. Lanjutkan?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.dangerColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(deleteTransactionProvider(transaction.id).future);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transaksi dihapus')));
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus transaksi: $e')),
        );
      }
    }
  }
}
