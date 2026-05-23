import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/theme/app_color_extension.dart';
import 'package:sisasaku/core/constants/app_strings.dart';
import 'package:sisasaku/features/category/domain/entities/category_entity.dart';
import 'package:sisasaku/features/category/presentation/providers/category_provider.dart';
import 'package:sisasaku/routes/app_router.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  bool _isExpense = true;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: context.colors.bgSecondary,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.decorativeBlurOf(context, alpha: 0.4),
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
                      AppSpacing.md,
                    ),
                    child: const AppPageHeader(
                      title: 'Kategori Transaksi',
                      subtitle:
                          'Atur kategori untuk pencatatan keuangan yang lebih rapi.',
                      showBackButton: true,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildToggle(),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: categoriesAsync.when(
                    data: (categories) {
                      final filtered = categories.where((c) {
                        if (_isExpense) {
                          return !_isIncomeCategory(c.nama);
                        } else {
                          return _isIncomeCategory(c.nama);
                        }
                      }).toList();

                      return SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: AppSpacing.md,
                              crossAxisSpacing: AppSpacing.md,
                              childAspectRatio: 1.05,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          if (index == filtered.length) {
                            return _AddNewCard(
                              onTap: () => context.push(AppRouter.addCategory),
                            );
                          }
                          final category = filtered[index];
                          return _CategoryCard(
                            category: category,
                            onEdit: () {
                              context.push('/category/${category.id}/edit');
                            },
                            onDelete: () => _confirmDeleteCategory(category),
                          );
                        }, childCount: filtered.length + 1),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, stack) => const SliverToBoxAdapter(
                      child: Center(child: Text(AppStrings.error)),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: AppStrings.pengeluaran,
              isActive: _isExpense,
              onTap: () => setState(() => _isExpense = true),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: AppStrings.pemasukan,
              isActive: !_isExpense,
              onTap: () => setState(() => _isExpense = false),
            ),
          ),
        ],
      ),
    );
  }

  bool _isIncomeCategory(String nama) {
    final incomeNames = ['gaji', 'bonus', 'investasi', 'hadiah', 'penjualan'];
    return incomeNames.contains(nama.toLowerCase());
  }

  Future<void> _confirmDeleteCategory(CategoryEntity category) async {
    final confirmed = await FeedbackDialog.showConfirm(
      context,
      title: 'Hapus Kategori',
      message: 'Apakah Anda yakin ingin menghapus kategori "${category.nama}"?',
      actionLabel: 'Hapus',
      cancelLabel: 'Batal',
    );

    if (confirmed && mounted) {
      try {
        await ref.read(deleteCategoryProvider(category.id).future);
        if (mounted) {
          FeedbackDialog.showSuccess<void>(
            context,
            title: 'Kategori dihapus',
            message: 'Kategori "${category.nama}" berhasil dihapus.',
          );
        }
      } catch (e) {
        if (mounted) {
          FeedbackDialog.showError<void>(
            context,
            title: 'Gagal menghapus kategori',
            message: e.toString(),
            actionLabel: 'Oke',
          );
        }
      }
    }
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? context.colors.bgPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: isActive
              ? [
                  const BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isActive ? 14 : 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            height: 1.4,
            color: isActive ? context.colors.textPrimary : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  static final Map<String, IconData> _iconMap = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'shopping_bag': Icons.shopping_bag,
    'favorite': Icons.favorite,
    'sports_esports': Icons.sports_esports,
    'school': Icons.school,
    'medical_services': Icons.medical_services,
    'flight': Icons.flight,
    'movie': Icons.movie,
    'receipt': Icons.receipt,
    'local_grocery_store': Icons.local_grocery_store,
  };

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primaryColor;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primaryColor;
    }
  }

  Color _lightColor(Color base) {
    final hsl = HSLColor.fromColor(base);
    final lightness = (hsl.lightness + 0.2).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  Color _darkColor(Color base) {
    final hsl = HSLColor.fromColor(base);
    final lightness = (hsl.lightness - 0.2).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  IconData _getIcon() {
    return _iconMap[category.ikon] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _parseColor(category.warna);
    final lightColor = _lightColor(baseColor);
    final darkColor = _darkColor(baseColor);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.borderColor.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 18),
              color: context.colors.textSecondary,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(28, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppColors.dangerColor,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(28, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: lightColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIcon(), color: darkColor, size: 28),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  category.nama,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddNewCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddNewCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: context.colors.borderColor.withValues(alpha: 0.5),
              style: BorderStyle.solid,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.bgTertiary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: context.colors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tambah Baru',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
