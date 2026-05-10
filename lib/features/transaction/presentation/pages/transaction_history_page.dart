import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/utils/category_ui_helpers.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';
import 'package:sisasaku/features/category/presentation/providers/category_provider.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';
import 'package:sisasaku/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:sisasaku/routes/app_router.dart';

class TransactionHistoryPage extends ConsumerStatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  ConsumerState<TransactionHistoryPage> createState() =>
      _TransactionHistoryPageState();
}

class _TransactionHistoryPageState
    extends ConsumerState<TransactionHistoryPage> {
  String _filter = 'all';
  String _sortBy = 'newest';
  String _searchQuery = '';
  bool _isSearching = false;
  final _searchController = TextEditingController();
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hari ini';
    } else if (dateOnly == yesterday) {
      return 'Kemarin';
    } else {
      final hari = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
      final bulan = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${hari[date.weekday % 7]}, ${date.day} ${bulan[date.month - 1]} ${date.year}';
    }
  }

  Future<void> _deleteTransaction(String id) async {
    try {
      await ref.read(deleteTransactionProvider(id).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus transaksi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthlyTransactions = ref.watch(
      monthlyTransactionsProvider((_currentMonth, _currentYear)),
    );
    final monthlyIncome = ref.watch(
      monthlyIncomeProvider((_currentMonth, _currentYear)),
    );
    final monthlyExpense = ref.watch(
      monthlyExpenseProvider((_currentMonth, _currentYear)),
    );
    final categoriesAsync = ref.watch(categoriesProvider);

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
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildMonthSelector(),
                  const SizedBox(height: AppSpacing.md),
                  _buildSummaryCards(monthlyIncome, monthlyExpense),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFilterChips(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTransactionList(monthlyTransactions, categoriesAsync),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (_isSearching) {
      return Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'Cari transaksi...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _isSearching = false;
                _searchQuery = '';
              });
            },
            child: const Text(
              'Batal',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textSecondary,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.bgSecondary,
          ),
        ),
        const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _isSearching = true),
          icon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.bgSecondary,
          ),
        ),
      ],
    );
  }

  String get _monthLabel {
    final bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${bulan[_currentMonth - 1]} $_currentYear';
  }

  void _previousMonth() {
    setState(() {
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
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
            onPressed: _previousMonth,
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            _monthLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    AsyncValue<double> incomeAsync,
    AsyncValue<double> expenseAsync,
  ) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Pemasukan',
            amount: incomeAsync.when(
              data: (v) => v,
              loading: () => 0,
              error: (_, _) => 0,
            ),
            icon: Icons.arrow_downward,
            iconColor: AppColors.successColor,
            bgColor: AppColors.bgPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SummaryCard(
            label: 'Pengeluaran',
            amount: expenseAsync.when(
              data: (v) => v,
              loading: () => 0,
              error: (_, _) => 0,
            ),
            icon: Icons.arrow_upward,
            iconColor: AppColors.tertiary,
            bgColor: AppColors.bgPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      ('Semua', 'all'),
      ('Pemasukan', 'income'),
      ('Pengeluaran', 'expense'),
    ];

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (label, value) in filters)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Material(
                      color: _filter == value
                          ? AppColors.primaryColor
                          : AppColors.bgPrimary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: InkWell(
                        onTap: () => setState(() => _filter = value),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: _filter == value
                                  ? AppColors.primaryColor
                                  : AppColors.borderColor,
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: _filter == value
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Material(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: InkWell(
            onTap: _showFilterBottomSheet,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tune, color: AppColors.textSecondary, size: 16),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                MediaQuery.of(context).padding.bottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderColor,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Urutkan',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _buildSortChip('Terbaru', 'newest', setModalState),
                      _buildSortChip('Terlama', 'oldest', setModalState),
                      _buildSortChip('Nominal Tertinggi', 'highest', setModalState),
                      _buildSortChip('Nominal Terendah', 'lowest', setModalState),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Tipe',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _buildTypeChip('Semua', 'all', setModalState),
                      _buildTypeChip('Pemasukan', 'income', setModalState),
                      _buildTypeChip('Pengeluaran', 'expense', setModalState),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _sortBy = 'newest';
                              _filter = 'all';
                            });
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Terapkan',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip(String label, String value, StateSetter setModalState) {
    final isActive = _sortBy == value;
    return Material(
      color: isActive ? AppColors.primaryLight : AppColors.bgSecondary,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: () {
          setModalState(() => _sortBy = value);
          setState(() {});
        },
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isActive ? AppColors.primaryColor : AppColors.borderColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primaryColor : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String value, StateSetter setModalState) {
    final isActive = _filter == value;
    return Material(
      color: isActive ? AppColors.primaryLight : AppColors.bgSecondary,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: () {
          setModalState(() => _filter = value);
          setState(() {});
        },
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isActive ? AppColors.primaryColor : AppColors.borderColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primaryColor : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    AsyncValue<List<TransactionEntity>> transactionsAsync,
    AsyncValue<List<dynamic>> categoriesAsync,
  ) {
    return transactionsAsync.when(
      data: (transactions) {
        final categories = categoriesAsync.when(
          data: (list) => list,
          loading: () => <dynamic>[],
          error: (err, stack) => <dynamic>[],
        );

        var filtered = _filter == 'all'
            ? transactions
            : transactions.where((t) {
                if (_filter == 'income') return t.jenis == TransactionType.income;
                return t.jenis == TransactionType.expense;
              }).toList();

        final categoryMap = {for (final c in categories) c.id: c};

        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          filtered = filtered.where((t) {
            final cat = categoryMap[t.idKategori];
            final catName = cat?.nama?.toString().toLowerCase() ?? '';
            final desc = t.deskripsi?.toLowerCase() ?? '';
            return catName.contains(q) || desc.contains(q);
          }).toList();
        }

        switch (_sortBy) {
          case 'highest':
            filtered.sort((a, b) => b.nominal.compareTo(a.nominal));
          case 'lowest':
            filtered.sort((a, b) => a.nominal.compareTo(b.nominal));
          case 'oldest':
            filtered.sort((a, b) => a.tanggal.compareTo(b.tanggal));
          case 'newest':
            filtered.sort((a, b) => b.tanggal.compareTo(a.tanggal));
          default:
            break;
        }

        if (filtered.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl2),
              child: Column(
                children: [
                  Icon(
                    _searchQuery.isNotEmpty ? Icons.search_off : Icons.receipt_long,
                    color: AppColors.textSecondary,
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Transaksi tidak ditemukan'
                        : 'Belum ada transaksi',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final groups = <String, List<TransactionEntity>>{};
        for (final t in filtered) {
          final label = _formatDateLabel(t.tanggal);
          groups.putIfAbsent(label, () => []).add(t);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xs,
                  bottom: AppSpacing.sm,
                ),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
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
                  child: Column(
                    children: List.generate(entry.value.length, (index) {
                      final tx = entry.value[index];
                      final cat = categoryMap[tx.idKategori];
                      final catName = cat?.nama?.toString() ?? 'Tidak diketahui';
                      final catIcon = CategoryUiHelpers.parseIcon(cat?.ikon?.toString() ?? 'category');
                      final catColor = CategoryUiHelpers.parseColor(cat?.warna?.toString() ?? '#9CA3AF');
                      final isIncome = tx.jenis == TransactionType.income;

                      return Dismissible(
                        key: Key(tx.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: AppColors.dangerColor,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppSpacing.lg),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) => _deleteTransaction(tx.id),
                        child: _TransactionRow(
                          title: tx.deskripsi ?? catName,
                          category: catName,
                          amount: tx.nominal,
                          isIncome: isIncome,
                          icon: catIcon,
                          iconColor: catColor,
                          showDivider: index != entry.value.length - 1,
                          onTap: () => context.push(
                            AppRouter.transactionDetail.replaceAll(':id', tx.id),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Gagal memuat transaksi: $err',
            style: const TextStyle(color: AppColors.dangerColor),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
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
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              color: iconColor,
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

class _TransactionRow extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final Color iconColor;
  final bool showDivider;
  final VoidCallback? onTap;

  const _TransactionRow({
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.iconColor,
    required this.showDivider,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
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
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          category,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(amount)}',
                    style: TextStyle(
                      color: isIncome ? AppColors.successColor : AppColors.tertiary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (showDivider)
              const Divider(
                height: 1,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
                color: AppColors.borderColor,
              ),
          ],
        ),
      ),
    );
  }
}
