import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/core/theme/app_color_extension.dart';
import 'package:sisasaku/core/utils/category_ui_helpers.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';
import 'package:sisasaku/features/category/presentation/providers/category_provider.dart';
import 'package:sisasaku/features/transaction/domain/entities/transaction_entity.dart';
import 'package:sisasaku/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';
import 'package:uuid/uuid.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  bool _isExpense = true;
  bool _isLoading = false;
  final _nominalController = TextEditingController();
  final _catatanController = TextEditingController();
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  final _hariList = const ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
  final _bulanList = const [
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

  @override
  void dispose() {
    _nominalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  String get _formattedDate {
    return '${_hariList[_selectedDate.weekday % 7]}, '
        '${_selectedDate.day} ${_bulanList[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  static const _uuid = Uuid();

  Future<void> _submit() async {
    final nominal = CurrencyFormatter.parse(_nominalController.text);
    if (nominal <= 0) {
      _showErrorDialog(
        title: 'Nominal belum valid',
        message: 'Nominal harus lebih dari 0.',
      );
      return;
    }
    if (_selectedCategoryId == null) {
      _showErrorDialog(
        title: 'Kategori belum dipilih',
        message: 'Silakan pilih kategori terlebih dahulu.',
      );
      return;
    }

    final transaction = TransactionEntity(
      id: _uuid.v4(),
      nominal: nominal,
      jenis: _isExpense ? TransactionType.expense : TransactionType.income,
      tanggal: _selectedDate,
      idKategori: _selectedCategoryId!,
      deskripsi: _catatanController.text.isEmpty
          ? null
          : _catatanController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: false,
    );

    setState(() => _isLoading = true);

    try {
      final repository = await ref.read(transactionRepositoryProvider.future);
      await repository.addTransaction(transaction);
      if (mounted) {
        await FeedbackDialog.showSuccess<void>(
          context,
          title: 'Transaksi berhasil disimpan',
          message: 'Data transaksi sudah masuk ke daftar.',
          onAction: () {
            if (mounted) {
              context.pop();
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          title: 'Gagal menyimpan transaksi',
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog({required String title, required String message}) {
    FeedbackDialog.showError<void>(
      context,
      title: title,
      message: message,
      actionLabel: 'Oke',
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: const AppPageHeader(
                title: 'Catat Transaksi',
                showBackButton: true,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildToggle(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildNominalField(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildDateField(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildKategoriField(categoriesAsync),
                    const SizedBox(height: AppSpacing.xl),
                    _buildCatatanField(),
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

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.bgTertiary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              icon: Icons.arrow_upward,
              label: 'Pengeluaran',
              isActive: _isExpense,
              onTap: () => setState(() => _isExpense = true),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              icon: Icons.arrow_downward,
              label: 'Pemasukan',
              isActive: !_isExpense,
              onTap: () => setState(() => _isExpense = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? context.colors.bgPrimary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      elevation: isActive ? 1 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive
                    ? (_isExpense
                          ? AppColors.dangerColor
                          : AppColors.primaryColor)
                    : context.colors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? (_isExpense
                            ? AppColors.dangerColor
                            : AppColors.primaryColor)
                      : context.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNominalField() {
    return AppMoneyField(
      controller: _nominalController,
      label: 'Nominal',
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        const _ThousandSeparatorFormatter(),
      ],
    );
  }

  Widget _buildDateField() {
    return AppSelectableField(
      label: 'Tanggal',
      value: _formattedDate,
      icon: Icons.calendar_today_outlined,
      onTap: _pickDate,
    );
  }

  Widget _buildKategoriField(AsyncValue<List<dynamic>> categoriesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppFieldLabel(label: 'Kategori'),
        const SizedBox(height: AppSpacing.md),
        categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) {
              return Text(
                'Belum ada kategori',
                style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
              );
            }
            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: categories.map((cat) {
                final isSelected = _selectedCategoryId == cat.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryId = cat.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight
                          : context.colors.bgSecondary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : context.colors.borderColor.withValues(alpha: 0.35),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CategoryUiHelpers.parseIcon(cat.ikon),
                          color: isSelected
                              ? AppColors.primaryColor
                              : context.colors.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          cat.nama,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primaryColor
                                : context.colors.textSecondary,
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
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text(
            'Gagal memuat kategori: $err',
            style: const TextStyle(color: AppColors.dangerColor),
          ),
        ),
      ],
    );
  }

  Widget _buildCatatanField() {
    return AppModernTextField(
      controller: _catatanController,
      label: 'Catatan',
      optionalText: '(opsional)',
      hint: 'Tambah catatan...',
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: _isLoading ? context.colors.textSecondary : AppColors.primaryColor,
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
                    'Simpan Transaksi',
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

class _ThousandSeparatorFormatter extends TextInputFormatter {
  const _ThousandSeparatorFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final numeric = newValue.text.replaceAll('.', '');
    if (numeric.isEmpty) return const TextEditingValue(text: '');

    final buffer = StringBuffer();
    for (int i = 0; i < numeric.length; i++) {
      if (i > 0 && (numeric.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(numeric[i]);
    }

    final text = buffer.toString();
    final offsetDelta = text.length - newValue.text.length;
    final newOffset = (newValue.selection.end + offsetDelta).clamp(
      0,
      text.length,
    );

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}
