import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/features/bill/presentation/providers/bill_provider.dart';
import 'package:sisasaku/features/category/presentation/providers/category_provider.dart';
import 'package:sisasaku/features/dashboard/presentation/widgets/bill_warning_card.dart';
import 'package:sisasaku/features/dashboard/presentation/widgets/quick_action_grid.dart';
import 'package:sisasaku/features/dashboard/presentation/widgets/saldo_card.dart';
import 'package:sisasaku/features/dashboard/presentation/widgets/transaction_row.dart';
import 'package:sisasaku/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:sisasaku/routes/app_router.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  static const _headerAvatarUrl =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=160&q=80';

  IconData _parseIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'directions_bus':
        return Icons.directions_bus_rounded;
      case 'home_work':
        return Icons.home_work_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'local_cafe':
        return Icons.local_cafe_rounded;
      case 'phone_iphone':
        return Icons.phone_iphone_rounded;
      case 'more_horiz':
        return Icons.more_horiz_rounded;
      case 'payments':
        return Icons.payments_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'shopping_cart':
        return Icons.shopping_cart_rounded;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.textSecondary;
    }
  }

  String _formatWaktu(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    if (dateOnly == today) {
      return 'Hari ini, $timeStr';
    } else if (dateOnly == yesterday) {
      return 'Kemarin, $timeStr';
    } else {
      final diff = today.difference(dateOnly).inDays;
      if (diff == 2) {
        return '2 Hari lalu, $timeStr';
      }
      final hari = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
      final bulan = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${hari[date.weekday % 7]}, ${date.day} ${bulan[date.month - 1]} ${date.year}, $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthlyTransactions = ref.watch(
      monthlyTransactionsProvider((now.month, now.year)),
    );
    final monthlyIncome = ref.watch(
      monthlyIncomeProvider((now.month, now.year)),
    );
    final monthlyExpense = ref.watch(
      monthlyExpenseProvider((now.month, now.year)),
    );
    final upcomingBills = ref.watch(upcomingBillsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: Stack(
        children: [
          // Decorative atmospheric layers
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
            top: 320,
            right: -60,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
              child: Container(
                width: 200,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withValues(alpha: 0.06),
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
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.bgPrimary,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const ClipOval(
                          child: Image(
                            image: NetworkImage(_headerAvatarUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat pagi,',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Andi Pratama 👋',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {},
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: AppColors.textPrimary,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.dangerColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.bgSecondary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Saldo Card
                  monthlyIncome.when(
                    data: (income) => monthlyExpense.when(
                      data: (expense) => SaldoCard(
                        saldo: income - expense,
                        pemasukan: income,
                        pengeluaran: expense,
                      ),
                      loading: () => const _SectionLoader(),
                      error: (err, stack) => Text('Error: $err'),
                    ),
                    loading: () => const _SectionLoader(),
                    error: (err, stack) => Text('Error: $err'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Bill Warning Card
                  upcomingBills.when(
                    data: (bills) {
                      if (bills.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final bill = bills.first;
                      return BillWarningCard(
                        nama: bill.nama,
                        nominal: bill.nominal ?? 0,
                        status: 'Jatuh tempo dalam H-2',
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (err, stack) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Aksi Cepat
                  Text(
                    'Aksi Cepat',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  QuickActionGrid(
                    items: [
                      QuickActionItem(
                        label: 'Catat',
                        icon: Icons.edit_document,
                        backgroundColor: AppColors.primaryLight,
                        iconColor: AppColors.primaryColor,
                        onTap: () => context.push(AppRouter.addTransaction),
                      ),
                      QuickActionItem(
                        label: 'Tagihan',
                        icon: Icons.receipt_long_outlined,
                        backgroundColor: const Color(0xFFFAEEDA),
                        iconColor: AppColors.warningDark,
                        onTap: () => context.go(AppRouter.bill),
                      ),
                      QuickActionItem(
                        label: 'Analitik',
                        icon: Icons.analytics_outlined,
                        backgroundColor: const Color(0xFFFFDAD7),
                        iconColor: AppColors.dangerColor,
                        onTap: () => context.go(AppRouter.analytics),
                      ),
                      QuickActionItem(
                        label: 'Kategori',
                        icon: Icons.category_outlined,
                        backgroundColor: AppColors.bgTertiary,
                        iconColor: AppColors.textSecondary,
                        onTap: () => context.push(AppRouter.category),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Transaksi Terbaru
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaksi Terbaru',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRouter.transactionHistory),
                        child: Text(
                          'Lihat Semua',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: monthlyTransactions.when(
                        data: (transactions) {
                          if (transactions.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Text(
                                  'Belum ada transaksi',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: AppColors.textSecondary),
                                ),
                              ),
                            );
                          }

                          final recentTransactions =
                              transactions.take(3).toList();

                          return categoriesAsync.when(
                            data: (categories) {
                              return Column(
                                children: List.generate(
                                  recentTransactions.length,
                                  (index) {
                                    final transaction =
                                        recentTransactions[index];
                                    final cat = categories.cast<dynamic>().firstWhere(
                                      (c) => c.id == transaction.idKategori,
                                      orElse: () => null,
                                    );
                                    final catName =
                                        cat?.nama?.toString() ?? 'Tidak diketahui';
                                    final catIcon = _parseIcon(
                                        cat?.ikon?.toString() ?? 'category');
                                    final catColor = _parseColor(
                                        cat?.warna?.toString() ?? '#9CA3AF');

                                    return TransactionRow(
                                      kategoriNama: catName,
                                      kategoriIcon: catIcon,
                                      kategoriColor: catColor,
                                      waktu: _formatWaktu(transaction.tanggal),
                                      nominal: transaction.nominal,
                                      isIncome: transaction.jenis.label == 'masuk',
                                      showDivider: index !=
                                          recentTransactions.length - 1,
                                      onTap: () => context.push(
                                        AppRouter.transactionDetail.replaceAll(
                                          ':id',
                                          transaction.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            loading: () => const _SectionLoader(),
                            error: (err, stack) =>
                                Center(child: Text('Error: $err')),
                          );
                        },
                        loading: () => const _SectionLoader(),
                        error: (err, stack) =>
                            Center(child: Text('Error: $err')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLoader extends StatelessWidget {
  const _SectionLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
