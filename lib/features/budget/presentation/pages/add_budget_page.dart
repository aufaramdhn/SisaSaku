import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/features/budget/domain/entities/budget_entity.dart';
import 'package:sisasaku/features/budget/presentation/providers/budget_provider.dart';
import 'package:sisasaku/features/category/domain/entities/category_entity.dart';
import 'package:sisasaku/features/category/presentation/providers/category_provider.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';
import 'package:uuid/uuid.dart';

class AddBudgetPage extends ConsumerStatefulWidget {
  const AddBudgetPage({super.key});

  @override
  ConsumerState<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends ConsumerState<AddBudgetPage> {
  String? _selectedCategoryId;
  String _selectedCategoryName = 'Makan';
  final _nominalController = TextEditingController();
  bool _isMonthly = true;

  final List<({String name, IconData icon, Color color})> _categories = [
    (name: 'Makan', icon: Icons.restaurant, color: AppColors.warningColor),
    (
      name: 'Transportasi',
      icon: Icons.directions_bus,
      color: AppColors.textSecondary,
    ),
    (name: 'Kos', icon: Icons.home_work, color: AppColors.primaryColor),
    (name: 'Belanja', icon: Icons.shopping_bag, color: AppColors.tertiary),
    (name: 'Jajan', icon: Icons.local_cafe, color: AppColors.warningDark),
    (name: 'Pulsa', icon: Icons.phone_iphone, color: AppColors.successColor),
    (name: 'Lainnya', icon: Icons.more_horiz, color: AppColors.textSecondary),
  ];

  @override
  void dispose() {
    _nominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(categoriesProvider).value ?? const <CategoryEntity>[];
    final categoryOptions = categories.isEmpty
        ? _categories
              .map(
                (cat) => (
                  id: cat.name.toLowerCase(),
                  name: cat.name,
                  icon: cat.icon,
                  color: cat.color,
                ),
              )
              .toList()
        : categories
              .map(
                (cat) => (
                  id: cat.id,
                  name: cat.nama,
                  icon: _iconForName(cat.ikon),
                  color: _colorForHex(cat.warna),
                ),
              )
              .toList();
    _selectedCategoryId ??= categoryOptions.isNotEmpty
        ? categoryOptions.first.id
        : null;
    if (categoryOptions.isNotEmpty &&
        !categoryOptions.any((cat) => cat.id == _selectedCategoryId)) {
      _selectedCategoryId = categoryOptions.first.id;
      _selectedCategoryName = categoryOptions.first.name;
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimaryOf(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: const AppPageHeader(
                title: 'Tambah Anggaran',
                showBackButton: true,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategori',
                      style: TextStyle(
                        color: AppColors.textSecondaryOf(context),
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: categoryOptions.map((cat) {
                        final isSelected = _selectedCategoryId == cat.id;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedCategoryId = cat.id;
                            _selectedCategoryName = cat.name;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : AppColors.bgSecondaryOf(context),
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat.icon,
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : AppColors.textSecondaryOf(context),
                                  size: 16,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : AppColors.textSecondaryOf(context),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Limit Nominal',
                          style: TextStyle(
                            color: AppColors.textSecondaryOf(context),
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                            height: 1.4,
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
                            Expanded(
                              child: TextField(
                                controller: _nominalController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 28,
                                  height: 1.2,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                    color: AppColors.textSecondaryOf(context),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(color: AppColors.borderColorOf(context), height: 1),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.bgTertiaryOf(context),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildToggleButton(
                              label: 'Bulanan',
                              isActive: _isMonthly,
                              onTap: () => setState(() => _isMonthly = true),
                            ),
                          ),
                          Expanded(
                            child: _buildToggleButton(
                              label: 'Mingguan',
                              isActive: !_isMonthly,
                              onTap: () => setState(() => _isMonthly = false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
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
                    onTap: _saveBudget,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Simpan Anggaran',
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
          ],
        ),
      ),
    );
  }

  Future<void> _saveBudget() async {
    final amount = double.tryParse(_nominalController.text.trim());
    if (_selectedCategoryId == null || amount == null || amount <= 0) {
      await FeedbackDialog.showError<void>(
        context,
        title: 'Data belum lengkap',
        message: 'Pilih kategori dan masukkan limit nominal yang valid.',
        actionLabel: 'Oke',
      );
      return;
    }

    final now = DateTime.now();
    final budget = BudgetEntity(
      id: const Uuid().v4(),
      idKategori: _selectedCategoryId!,
      namaKategori: _selectedCategoryName,
      limit: amount,
      period: _isMonthly ? 'monthly' : 'weekly',
      month: now.month,
      year: now.year,
      createdAt: now,
      updatedAt: now,
      syncStatus: false,
    );

    try {
      await ref.read(addBudgetProvider(budget).future);
      if (mounted) context.pop();
    } catch (_) {
      if (!mounted) return;
      await FeedbackDialog.showError<void>(
        context,
        title: 'Gagal menyimpan',
        message: 'Coba lagi beberapa saat lagi.',
        actionLabel: 'Oke',
      );
    }
  }

  IconData _iconForName(String name) {
    return switch (name) {
      'restaurant' => Icons.restaurant,
      'directions_car' => Icons.directions_car,
      'home' => Icons.home,
      'shopping_bag' => Icons.shopping_bag,
      'payments' => Icons.payments,
      _ => Icons.category,
    };
  }

  Color _colorForHex(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.textSecondaryOf(context);
    }
  }

  Widget _buildToggleButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? AppColors.bgPrimaryOf(context) : Colors.transparent,
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
                  : AppColors.textSecondaryOf(context),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
