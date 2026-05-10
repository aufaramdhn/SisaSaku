import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/utils/category_ui_helpers.dart';
import 'package:sisasaku/features/category/domain/entities/category_entity.dart';
import 'package:sisasaku/features/category/presentation/providers/category_provider.dart';
import 'package:uuid/uuid.dart';

class AddCategoryPage extends ConsumerStatefulWidget {
  const AddCategoryPage({super.key});

  @override
  ConsumerState<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends ConsumerState<AddCategoryPage> {
  final _namaController = TextEditingController();
  String? _selectedIcon;
  String? _selectedColor;
  bool _isLoading = false;

  static const _uuid = Uuid();

  final List<Map<String, String>> _iconOptions = const [
    {'name': 'restaurant', 'label': 'Makanan'},
    {'name': 'directions_car', 'label': 'Transport'},
    {'name': 'home', 'label': 'Rumah'},
    {'name': 'shopping_bag', 'label': 'Belanja'},
    {'name': 'favorite', 'label': 'Kesehatan'},
    {'name': 'sports_esports', 'label': 'Hiburan'},
    {'name': 'school', 'label': 'Pendidikan'},
    {'name': 'medical_services', 'label': 'Medis'},
    {'name': 'flight', 'label': 'Travel'},
    {'name': 'movie', 'label': 'Film'},
    {'name': 'receipt', 'label': 'Tagihan'},
    {'name': 'local_grocery_store', 'label': 'Groceries'},
    {'name': 'payments', 'label': 'Gaji'},
    {'name': 'trending_up', 'label': 'Investasi'},
  ];

  final List<String> _colorOptions = const [
    '#1D9E75',
    '#E53935',
    '#FB8C00',
    '#1E88E5',
    '#8E24AA',
    '#FDD835',
    '#546E7A',
    '#D81B60',
    '#43A047',
    '#3949AB',
    '#00ACC1',
    '#6D4C41',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nama = _namaController.text.trim();
    if (nama.isEmpty) {
      _showSnackBar('Nama kategori harus diisi');
      return;
    }
    if (_selectedIcon == null) {
      _showSnackBar('Pilih ikon kategori');
      return;
    }
    if (_selectedColor == null) {
      _showSnackBar('Pilih warna kategori');
      return;
    }

    final category = CategoryEntity(
      id: _uuid.v4(),
      nama: nama,
      ikon: _selectedIcon!,
      warna: _selectedColor!,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: false,
    );

    setState(() => _isLoading = true);

    try {
      final repository = await ref.read(categoryRepositoryProvider.future);
      await repository.addCategory(category);
      if (mounted) {
        _showSnackBar('Kategori berhasil disimpan');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal menyimpan kategori: \$e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
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
                      backgroundColor: AppColors.bgSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Text(
                    'Tambah Kategori',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: AppColors.textPrimary,
                    ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNamaField(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildIconSelection(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildColorSelection(),
                    const SizedBox(height: AppSpacing.xl),
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
              child: _buildSubmitButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNamaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Kategori',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _namaController,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.4,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.label_outline, color: AppColors.textSecondary, size: 20),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            hintText: 'Contoh: Makanan, Transportasi',
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ikon',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: _iconOptions.map((iconOption) {
            final isSelected = _selectedIcon == iconOption['name'];
            final iconData = CategoryUiHelpers.parseIcon(iconOption['name']);
            return GestureDetector(
              onTap: () => setState(() => _selectedIcon = iconOption['name']),
              child: Container(
                width: 64,
                height: 72,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight : AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconData,
                      color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      iconOption['label']!,
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 10,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Warna',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: _colorOptions.map((colorHex) {
            final isSelected = _selectedColor == colorHex;
            final color = CategoryUiHelpers.parseColor(colorHex);
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = colorHex),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.textPrimary : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: _isLoading ? AppColors.textSecondary : AppColors.primaryColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: _isLoading ? null : _submit,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Simpan Kategori',
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
    );
  }
}
