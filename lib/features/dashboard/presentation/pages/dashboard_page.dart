import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/theme/app_color_extension.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/core/utils/category_ui_helpers.dart';
import 'package:sisasaku/features/bill/presentation/providers/bill_provider.dart';
import 'package:sisasaku/features/category/presentation/providers/category_provider.dart';
import 'package:sisasaku/features/dashboard/presentation/widgets/bill_warning_card.dart';
import 'package:sisasaku/features/dashboard/presentation/widgets/quick_action_grid.dart';
import 'package:sisasaku/features/dashboard/presentation/widgets/quick_action_more_sheet.dart';
import 'package:sisasaku/features/dashboard/presentation/widgets/saldo_card.dart';
import 'package:sisasaku/features/settings/presentation/providers/profile_provider.dart';
import 'package:sisasaku/features/dashboard/presentation/widgets/transaction_row.dart';
import 'package:sisasaku/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:sisasaku/routes/app_router.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
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
    final profileAsync = ref.watch(profileViewProvider);

    return Scaffold(
      backgroundColor: context.colors.bgSecondary,
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
                  color: AppColors.decorativeBlurOf(context, alpha: 0.4),
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
                      _DashboardAvatar(profileAsync: profileAsync),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greetingForHour(now.hour),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: context.colors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${profileAsync.valueOrNull?.displayName ?? 'Pengguna'} 👋',
                              style: Theme.of(context).textTheme.titleMedium
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
                                onTap: () =>
                                    context.push(AppRouter.notifications),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.notifications_none_rounded,
                                    color: context.colors.textPrimary,
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
                                    color: context.colors.bgSecondary,
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
                  Builder(
                    builder: (_) {
                      final income = monthlyIncome.when(
                        data: (v) => v,
                        loading: () => 0.0,
                        error: (_, _) => 0.0,
                      );
                      final expense = monthlyExpense.when(
                        data: (v) => v,
                        loading: () => 0.0,
                        error: (_, _) => 0.0,
                      );
                      final isLoading =
                          monthlyIncome.isLoading || monthlyExpense.isLoading;
                      if (isLoading) return const _SectionLoader();
                      return SaldoCard(
                        saldo: income - expense,
                        pemasukan: income,
                        pengeluaran: expense,
                        onDetailTap: () => context.go(AppRouter.analytics),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Bill Warning Card
                  upcomingBills.when(
                    data: (bills) {
                      if (bills.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final bill = bills.first;
                      final today = DateTime(now.year, now.month, now.day);
                      final dueDate = DateTime(
                        bill.tanggalJatuhTempo.year,
                        bill.tanggalJatuhTempo.month,
                        bill.tanggalJatuhTempo.day,
                      );
                      final daysRemaining =
                          dueDate.difference(today).inDays;

                      final String status;
                      if (daysRemaining > 0) {
                        status = 'Jatuh tempo dalam H-$daysRemaining';
                      } else if (daysRemaining == 0) {
                        status = 'Jatuh tempo hari ini';
                      } else {
                        status =
                            'Terlambat ${daysRemaining.abs()} hari';
                      }

                      return BillWarningCard(
                        nama: bill.nama,
                        nominal: bill.nominal ?? 0,
                        status: status,
                        onPayTap: () => context.push('/bill/${bill.id}'),
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
                  // Prepare quick action items; support more than 4 and a "Lainnya" drawer
                  Builder(
                    builder: (ctx) {
                      final allQuickActions = <QuickActionItem>[
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
                          backgroundColor: context.colors.bgTertiary,
                          iconColor: context.colors.textSecondary,
                          onTap: () => context.push(AppRouter.category),
                        ),
                        // Extras shown in the "Lainnya" drawer
                        QuickActionItem(
                          label: 'Anggaran',
                          icon: Icons.pie_chart_outline,
                          backgroundColor: context.colors.surfaceVariant,
                          iconColor: context.colors.textSecondary,
                          onTap: () => context.push(AppRouter.budget),
                        ),
                        QuickActionItem(
                          label: 'Hutang & Piutang',
                          icon: Icons.handshake_outlined,
                          backgroundColor: context.colors.surfaceVariant,
                          iconColor: context.colors.textSecondary,
                          onTap: () => context.push(AppRouter.debt),
                        ),
                      ];

                      return QuickActionGrid(
                        items: allQuickActions,
                        maxVisible: 4,
                        onShowMore: () =>
                            showQuickActionMoreSheet(ctx, allQuickActions),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Transaksi Terbaru
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaksi Terbaru',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRouter.transactionHistory),
                        child: Text(
                          'Lihat Semua',
                          style: Theme.of(context).textTheme.labelSmall
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
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: context.colors.textSecondary,
                                      ),
                                ),
                              ),
                            );
                          }

                          final recentTransactions = transactions
                              .take(3)
                              .toList();
                          final categories = categoriesAsync.when(
                            data: (list) => list,
                            loading: () => <dynamic>[],
                            error: (_, _) => <dynamic>[],
                          );
                          final categoryMap = {
                            for (final c in categories) c.id: c,
                          };

                          return Column(
                            children: List.generate(recentTransactions.length, (
                              index,
                            ) {
                              final transaction = recentTransactions[index];
                              final cat = categoryMap[transaction.idKategori];
                              final catName =
                                  cat?.nama?.toString() ?? 'Tidak diketahui';
                              final catIcon = CategoryUiHelpers.parseIcon(
                                cat?.ikon?.toString() ?? 'category',
                              );
                              final catColor = CategoryUiHelpers.parseColor(
                                cat?.warna?.toString() ?? '#9CA3AF',
                              );

                              return TransactionRow(
                                kategoriNama: catName,
                                kategoriIcon: catIcon,
                                kategoriColor: catColor,
                                waktu: _formatWaktu(transaction.tanggal),
                                nominal: transaction.nominal,
                                isIncome:
                                    transaction.jenis == TransactionType.income,
                                showDivider:
                                    index != recentTransactions.length - 1,
                                onTap: () => context.push(
                                  AppRouter.transactionDetail.replaceAll(
                                    ':id',
                                    transaction.id,
                                  ),
                                ),
                              );
                            }),
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

  String _greetingForHour(int hour) {
    if (hour < 11) return 'Selamat pagi,';
    if (hour < 15) return 'Selamat siang,';
    if (hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }
}

class _DashboardAvatar extends StatelessWidget {
  final AsyncValue<ProfileViewData> profileAsync;

  const _DashboardAvatar({required this.profileAsync});

  @override
  Widget build(BuildContext context) {
    return profileAsync.when(
      loading: () => const _AvatarFrame(initials: 'SS'),
      error: (_, _) => const _AvatarFrame(initials: 'SS'),
      data: (profile) => _AvatarFrame(
        initials: profile.initials,
        avatarPath: profile.avatarPath,
        avatarUrl: profile.avatarPath == null ? profile.avatarUrl : null,
      ),
    );
  }
}

class _AvatarFrame extends StatelessWidget {
  final String initials;
  final String? avatarPath;
  final String? avatarUrl;

  const _AvatarFrame({required this.initials, this.avatarPath, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final imageProvider = _buildImageProvider();
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.bgPrimary, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
        color: AppColors.primaryLight,
      ),
      child: ClipOval(
        child: imageProvider == null
            ? Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
              )
            : Image(
                image: imageProvider,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  ImageProvider<Object>? _buildImageProvider() {
    if (avatarPath != null && avatarPath!.isNotEmpty) {
      return FileImage(File(avatarPath!));
    }
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return NetworkImage(avatarUrl!);
    }
    return null;
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
