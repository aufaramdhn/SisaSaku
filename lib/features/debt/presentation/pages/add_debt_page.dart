import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/features/debt/domain/entities/debt_entity.dart';
import 'package:sisasaku/features/debt/presentation/providers/debt_provider.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';
import 'package:uuid/uuid.dart';

class AddDebtPage extends ConsumerStatefulWidget {
  const AddDebtPage({super.key});

  @override
  ConsumerState<AddDebtPage> createState() => _AddDebtPageState();
}

class _AddDebtPageState extends ConsumerState<AddDebtPage> {
  bool _isIOwe = true;
  final _personController = TextEditingController();
  final _nominalController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _personController.dispose();
    _nominalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                title: 'Tambah Hutang',
                showBackButton: true,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Tipe'),
                    const SizedBox(height: AppSpacing.sm),
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
                              label: 'Saya Pinjam',
                              isActive: _isIOwe,
                              onTap: () => setState(() => _isIOwe = true),
                            ),
                          ),
                          Expanded(
                            child: _buildToggleButton(
                              label: 'Saya Pinjamkan',
                              isActive: !_isIOwe,
                              onTap: () => setState(() => _isIOwe = false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildLabel('Nama Orang'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _personController,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Andi Pratama',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondaryOf(context),
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: AppColors.bgSecondaryOf(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildLabel('Nominal'),
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
                    const SizedBox(height: AppSpacing.lg),
                    _buildLabel('Tanggal'),
                    const SizedBox(height: AppSpacing.sm),
                    Material(
                      color: AppColors.bgSecondaryOf(context),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.textSecondaryOf(context),
                                size: 18,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '${_selectedDate.day} ${_monthName(_selectedDate.month)} ${_selectedDate.year}',
                                style: TextStyle(
                                  color: AppColors.textPrimaryOf(context),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.textSecondaryOf(context),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildLabel('Catatan (Opsional)'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondaryOf(context),
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: AppColors.bgSecondaryOf(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
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
                    onTap: _saveDebt,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Simpan',
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

  Future<void> _saveDebt() async {
    final person = _personController.text.trim();
    final amount = double.tryParse(_nominalController.text.trim());
    if (person.isEmpty || amount == null || amount <= 0) {
      await FeedbackDialog.showError<void>(
        context,
        title: 'Data belum lengkap',
        message: 'Isi nama orang dan nominal yang valid.',
        actionLabel: 'Oke',
      );
      return;
    }

    final now = DateTime.now();
    final debt = DebtEntity(
      id: const Uuid().v4(),
      person: person,
      amount: amount,
      date: _selectedDate,
      notes: _notesController.text.trim(),
      type: _isIOwe ? 'i_owe' : 'they_owe',
      isSettled: false,
      createdAt: now,
      updatedAt: now,
      syncStatus: false,
    );

    try {
      await ref.read(addDebtProvider(debt).future);
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondaryOf(context),
        fontWeight: FontWeight.w400,
        fontSize: 11,
        height: 1.4,
      ),
    );
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

  String _monthName(int month) {
    const names = [
      '',
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
    return names[month];
  }
}
