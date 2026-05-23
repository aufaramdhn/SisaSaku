import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:sisasaku/shared/widgets/ui/ui.dart';

class EditTransactionPage extends ConsumerStatefulWidget {
  final String transactionId;

  const EditTransactionPage({super.key, required this.transactionId});

  @override
  ConsumerState<EditTransactionPage> createState() =>
      _EditTransactionPageState();
}

class _EditTransactionPageState extends ConsumerState<EditTransactionPage> {
  bool _isExpense = true;
  bool _isLoading = false;
  bool _isInitialized = false;

  final _nominalController = TextEditingController();
  final _catatanController = TextEditingController();
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  TransactionEntity? _initialTransaction;

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

  void _initializeForm(TransactionEntity transaction) {
    _initialTransaction = transaction;
    _isExpense = transaction.jenis == TransactionType.expense;
    _selectedCategoryId = transaction.idKategori;
    _selectedDate = transaction.tanggal;
    _nominalController.text = CurrencyFormatter.format(
      transaction.nominal,
    ).replaceAll('Rp ', '');
    _catatanController.text = transaction.deskripsi ?? '';
  }

  void _ensureInitialized(TransactionEntity transaction) {
    if (_isInitialized) return;
    _isInitialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _initializeForm(transaction));
    });
  }

  bool _isIncomeCategory(String nama) {
    final incomeNames = ['gaji', 'bonus', 'investasi', 'hadiah', 'penjualan'];
    return incomeNames.contains(nama.toLowerCase());
  }

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
    if (_initialTransaction == null) return;

    final updated = _initialTransaction!.copyWith(
      nominal: nominal,
      jenis: _isExpense ? TransactionType.expense : TransactionType.income,
      tanggal: _selectedDate,
      idKategori: _selectedCategoryId,
      deskripsi: _catatanController.text.isEmpty
          ? null
          : _catatanController.text,
      updatedAt: DateTime.now(),
      syncStatus: false,
    );

    setState(() => _isLoading = true);

    try {
      await ref.read(updateTransactionProvider(updated).future);
      if (mounted) {
        await FeedbackDialog.showSuccess<void>(
          context,
          title: 'Transaksi berhasil diperbarui',
          message: 'Perubahan data transaksi sudah disimpan.',
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
          title: 'Gagal memperbarui transaksi',
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
    final transactionAsync = ref.watch(
      transactionByIdProvider(widget.transactionId),
    );
    final categoriesAsync = ref.watch(categoriesProvider);

    return transactionAsync.when(
      data: (transaction) {
        if (transaction == null) {
          return _buildMissingState();
        }
        _ensureInitialized(transaction);
        return _buildScaffold(categoriesAsync);
      },
      loading: _buildLoadingState,
      error: (err, stack) => _buildErrorState(err),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: AppColors.bgPrimaryOf(context),
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(Object err) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimaryOf(context),
      body: Center(child: Text('Error: $err')),
    );
  }

  Widget _buildMissingState() {
    return Scaffold(
      backgroundColor: AppColors.bgPrimaryOf(context),
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

  Widget _buildScaffold(AsyncValue<List<CategoryEntity>> categoriesAsync) {
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
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.textSecondaryOf(context),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.bgSecondaryOf(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Edit Transaksi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildToggle(),
                    const SizedBox(height: 32),
                    _buildNominalField(),
                    const SizedBox(height: 32),
                    _buildDateField(),
                    const SizedBox(height: 32),
                    _buildKategoriField(categoriesAsync),
                    const SizedBox(height: 32),
                    _buildCatatanField(),
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
        color: AppColors.bgTertiaryOf(context),
        borderRadius: BorderRadius.circular(14),
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
      color: isActive ? AppColors.bgPrimaryOf(context) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      elevation: isActive ? 1 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.tertiary : AppColors.textSecondaryOf(context),
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? AppColors.tertiary
                      : AppColors.textSecondaryOf(context),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nominal',
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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  const _ThousandSeparatorFormatter(),
                ],
              ),
            ),
          ],
        ),
        Divider(color: AppColors.borderColorOf(context), height: 1),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal',
          style: TextStyle(
            color: AppColors.textSecondaryOf(context),
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderColorOf(context))),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondaryOf(context),
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _formattedDate,
                    style: TextStyle(
                      color: AppColors.textPrimaryOf(context),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondaryOf(context),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKategoriField(AsyncValue<List<CategoryEntity>> categoriesAsync) {
    return Column(
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
        categoriesAsync.when(
          data: (categories) {
            final filtered = categories.where((category) {
              final isIncome = _isIncomeCategory(category.nama);
              return _isExpense ? !isIncome : isIncome;
            }).toList();

            if (filtered.isEmpty) {
              return const Text('Belum ada kategori');
            }

            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: filtered.map((category) {
                final isSelected = _selectedCategoryId == category.id;
                final icon = CategoryUiHelpers.parseIcon(category.ikon);
                final color = CategoryUiHelpers.parseColor(category.warna);

                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategoryId = category.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight
                          : AppColors.bgSecondaryOf(context),
                      borderRadius: BorderRadius.circular(AppRadius.full),
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
                          icon,
                          color: isSelected ? AppColors.primaryColor : color,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          category.nama,
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
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const Text('Gagal memuat kategori'),
        ),
      ],
    );
  }

  Widget _buildCatatanField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Catatan',
              style: TextStyle(
                color: AppColors.textSecondaryOf(context),
                fontWeight: FontWeight.w400,
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '(opsional)',
              style: TextStyle(
                color: AppColors.textSecondaryOf(context).withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _catatanController,
          maxLines: 3,
          minLines: 1,
          style: TextStyle(
            color: AppColors.textPrimaryOf(context),
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.5,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
              borderSide: BorderSide(color: AppColors.borderColorOf(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
              borderSide: BorderSide(color: AppColors.borderColorOf(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            hintText: 'Tambah catatan...',
            hintStyle: TextStyle(
              color: AppColors.textSecondaryOf(context),
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: _isLoading ? AppColors.textSecondaryOf(context) : AppColors.primaryColor,
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
                    'Simpan Perubahan',
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
