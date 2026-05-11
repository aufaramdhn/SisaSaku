import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/constants/app_strings.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/core/services/notification_service.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';
import 'package:sisasaku/features/bill/domain/entities/bill_entity.dart';
import 'package:sisasaku/features/bill/presentation/providers/bill_provider.dart';
import 'package:sisasaku/routes/app_router.dart';

class BillPage extends ConsumerStatefulWidget {
  const BillPage({super.key});

  @override
  ConsumerState<BillPage> createState() => _BillPageState();
}

class _BillPageState extends ConsumerState<BillPage> {
  String _filter = 'all';

  String _formatRelativeDate(BillEntity bill) {
    if (bill.status == BillStatus.paid) return 'Lunas';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      bill.tanggalJatuhTempo.year,
      bill.tanggalJatuhTempo.month,
      bill.tanggalJatuhTempo.day,
    );
    final diff = dueDate.difference(today).inDays;

    if (diff < 0) {
      return 'Terlewat ${diff.abs()} hari';
    } else if (diff == 0) {
      return 'Hari ini';
    } else if (diff == 1) {
      return 'Besok';
    } else {
      return '$diff hari lagi';
    }
  }

  Color _dateColor(BillEntity bill) {
    if (bill.status == BillStatus.paid) return AppColors.textSecondary;
    if (bill.status == BillStatus.overdue) return AppColors.dangerColor;
    return AppColors.textSecondary;
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tagihan'),
        content: const Text('Tagihan akan dihapus permanen. Lanjutkan?'),
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

    return confirmed ?? false;
  }

  Future<void> _deleteBill(BillEntity bill) async {
    try {
      final localDatasource = await ref.read(
        billLocalDatasourceProvider.future,
      );
      final billModel = await localDatasource.getBillById(bill.id);
      if (billModel?.isarId != null) {
        await NotificationService().cancelBillReminder(billModel!.isarId!);
      }

      await ref.read(deleteBillProvider(bill.id).future);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tagihan dihapus')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus tagihan: $e')));
      }
    }
  }

  Future<void> _markBillPaid(BillEntity bill) async {
    try {
      await ref.read(
        updateBillStatusProvider((bill.id, BillStatus.paid)).future,
      );

      final localDatasource = await ref.read(
        billLocalDatasourceProvider.future,
      );
      final billModel = await localDatasource.getBillById(bill.id);
      if (billModel?.isarId != null) {
        await NotificationService().cancelBillReminder(billModel!.isarId!);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tagihan ditandai lunas')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengubah status: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final billsAsync = ref.watch(billsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warningColor.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
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
                        billsAsync.when(
                          data: (bills) {
                            final overdue = bills
                                .where((b) => b.status == BillStatus.overdue)
                                .toList();
                            final upcoming = bills
                                .where(
                                  (b) =>
                                      b.status == BillStatus.upcoming ||
                                      b.status == BillStatus.pending,
                                )
                                .toList();
                            final paid = bills
                                .where((b) => b.status == BillStatus.paid)
                                .toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFilterChips(
                                  overdue.length,
                                  upcoming.length,
                                  paid.length,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                _buildBillList(overdue, upcoming, paid),
                              ],
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, stack) =>
                              Center(child: Text('Error: $err')),
                        ),
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
  }

  Widget _buildBillList(
    List<BillEntity> overdue,
    List<BillEntity> upcoming,
    List<BillEntity> paid,
  ) {
    final allWidgets = <Widget>[];

    if (overdue.isNotEmpty && (_filter == 'all' || _filter == 'overdue')) {
      allWidgets.add(
        _buildSectionHeader(
          Icons.error,
          'Jatuh Tempo Terlewat',
          AppColors.dangerColor,
        ),
      );
      allWidgets.add(const SizedBox(height: AppSpacing.md));
      for (final bill in overdue) {
        allWidgets.add(
          _wrapDismissible(
            bill,
            _BillCard(
              icon: Icons.wifi,
              iconColor: AppColors.dangerColor,
              iconBgColor: AppColors.dangerLight,
              title: bill.nama,
              date: _formatRelativeDate(bill),
              dateColor: _dateColor(bill),
              amount: bill.nominal ?? 0,
              leftBorderColor: AppColors.dangerColor,
              backgroundColor: AppColors.bgPrimary,
              onTap: () =>
                  context.push(AppRouter.editBill.replaceAll(':id', bill.id)),
              onMarkPaid: () => _markBillPaid(bill),
            ),
          ),
        );
        allWidgets.add(const SizedBox(height: AppSpacing.md));
      }
    }

    if (upcoming.isNotEmpty && (_filter == 'all' || _filter == 'upcoming')) {
      allWidgets.add(
        _buildSectionHeader(Icons.warning, 'Mendekati', AppColors.warningDark),
      );
      allWidgets.add(const SizedBox(height: AppSpacing.md));
      for (final bill in upcoming) {
        allWidgets.add(
          _wrapDismissible(
            bill,
            _BillCard(
              icon: Icons.house,
              iconColor: AppColors.warningDark,
              iconBgColor: AppColors.warningLight,
              title: bill.nama,
              date: _formatRelativeDate(bill),
              dateColor: _dateColor(bill),
              amount: bill.nominal ?? 0,
              leftBorderColor: AppColors.warningColor,
              backgroundColor: const Color(0xFFFFFDF7),
              onTap: () =>
                  context.push(AppRouter.editBill.replaceAll(':id', bill.id)),
              onMarkPaid: () => _markBillPaid(bill),
            ),
          ),
        );
        allWidgets.add(const SizedBox(height: AppSpacing.md));
      }
    }

    if (paid.isNotEmpty && (_filter == 'all' || _filter == 'paid')) {
      allWidgets.add(
        _buildSectionHeader(
          Icons.check_circle,
          'Sudah Lunas',
          AppColors.successColor,
        ),
      );
      allWidgets.add(const SizedBox(height: AppSpacing.md));
      for (final bill in paid) {
        allWidgets.add(
          _wrapDismissible(
            bill,
            _BillCard(
              icon: Icons.bolt,
              iconColor: AppColors.successColor,
              iconBgColor: AppColors.successLight,
              title: bill.nama,
              date: _formatRelativeDate(bill),
              dateColor: _dateColor(bill),
              amount: bill.nominal ?? 0,
              leftBorderColor: AppColors.borderColor,
              backgroundColor: AppColors.bgPrimary,
              isPaid: true,
              onTap: () =>
                  context.push(AppRouter.editBill.replaceAll(':id', bill.id)),
            ),
          ),
        );
        allWidgets.add(const SizedBox(height: AppSpacing.md));
      }
    }

    if (allWidgets.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl2),
          child: Text('Belum ada tagihan'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: allWidgets,
    );
  }

  Widget _wrapDismissible(BillEntity bill, Widget child) {
    return Dismissible(
      key: ValueKey(bill.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.dangerColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteBill(bill),
      child: child,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderColor),
              ),
              child: ClipOval(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBgMyN0wJVVIDL1jqqLqsvVr-NXIElQ56ONy6xUWvBQZY8I1V3X8w9yX0ORHJrJDSzL2MSlTxON3gq8oUhsGf9tvU4a_1qNvF1oijSI4Hhd9WGXe_UTMJfwzX5xSb90qB4TN7SxS76fgBqjuEQqXciapDSAWjT15V-VeaKE6krTzEq0Tb3TnQ7HjzNOSvUzAOxl5XFPRYltaRr3pSE7_rU6cKSQEOEZxAyi-FjawQBBsX9NsYSo6V0hnLrDP4B21fvE6rahVVph8AI',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primaryColor,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(int overdueCount, int upcomingCount, int paidCount) {
    final filters = [
      (
        'Overdue ($overdueCount)',
        'overdue',
        AppColors.dangerLight,
        AppColors.dangerColor,
        const Color(0xFFFFDAD6),
      ),
      (
        'Mendekati ($upcomingCount)',
        'upcoming',
        AppColors.warningLight,
        AppColors.warningDark,
        const Color(0xFFFFDDB7),
      ),
      (
        'Lunas ($paidCount)',
        'paid',
        AppColors.bgPrimary,
        AppColors.textSecondary,
        AppColors.borderColor,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (label, value, bgColor, textColor, borderColor) in filters)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Material(
                color: _filter == value || (_filter == 'all' && value != '')
                    ? bgColor
                    : AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _filter = _filter == value ? 'all' : value;
                    });
                  },
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _BillCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String date;
  final Color dateColor;
  final double amount;
  final Color leftBorderColor;
  final Color backgroundColor;
  final bool isPaid;
  final VoidCallback? onTap;
  final VoidCallback? onMarkPaid;

  const _BillCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.date,
    required this.dateColor,
    required this.amount,
    required this.leftBorderColor,
    required this.backgroundColor,
    this.isPaid = false,
    this.onTap,
    this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border(
            left: BorderSide(color: leftBorderColor, width: 3),
            top: const BorderSide(color: AppColors.borderColor),
            right: const BorderSide(color: AppColors.borderColor),
            bottom: const BorderSide(color: AppColors.borderColor),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
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
                    title,
                    style: TextStyle(
                      color: isPaid
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.4,
                      decoration: isPaid ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: dateColor, size: 14),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        date,
                        style: TextStyle(
                          color: dateColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(amount),
                  style: TextStyle(
                    color: isPaid
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.3,
                    decoration: isPaid ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (!isPaid) ...[
                  const SizedBox(height: AppSpacing.xs),
                  GestureDetector(
                    onTap: onMarkPaid,
                    child: const Text(
                      'Bayar',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
