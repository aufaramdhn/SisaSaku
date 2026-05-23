import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/enums.dart';
import 'package:sisasaku/core/services/notification_service.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';
import 'package:sisasaku/core/utils/date_formatter.dart';
import 'package:sisasaku/features/bill/domain/entities/bill_entity.dart';
import 'package:sisasaku/features/bill/presentation/providers/bill_provider.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';
import 'package:uuid/uuid.dart';

class AddBillPage extends ConsumerStatefulWidget {
  const AddBillPage({super.key});

  @override
  ConsumerState<AddBillPage> createState() => _AddBillPageState();
}

class _AddBillPageState extends ConsumerState<AddBillPage> {
  final _namaController = TextEditingController();
  final _nominalController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  String _pengingat = 'H-3';
  bool _isRutin = true;
  bool _isLoading = false;

  final _pengingatOptions = const ['H-1', 'H-3', 'H-7', 'Hari H', 'Tidak ada'];

  static const _uuid = Uuid();

  @override
  void dispose() {
    _namaController.dispose();
    _nominalController.dispose();
    super.dispose();
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

  String get _formattedDate {
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
    return '${hari[_selectedDate.weekday % 7]}, '
        '${_selectedDate.day} ${bulan[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  DateTime? _calculateWaktuPengingat() {
    switch (_pengingat) {
      case 'H-1':
        return DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day - 1,
          8,
          0,
        );
      case 'H-3':
        return DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day - 3,
          8,
          0,
        );
      case 'H-7':
        return DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day - 7,
          8,
          0,
        );
      case 'Hari H':
        return DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          8,
          0,
        );
      case 'Tidak ada':
        return null;
      default:
        return null;
    }
  }

  Future<void> _submit() async {
    final nama = _namaController.text.trim();
    if (nama.isEmpty) {
      _showErrorDialog(
        title: 'Nama tagihan belum diisi',
        message: 'Silakan isi nama tagihan terlebih dahulu.',
      );
      return;
    }

    final nominal = CurrencyFormatter.parse(_nominalController.text);
    if (nominal <= 0) {
      _showErrorDialog(
        title: 'Nominal belum valid',
        message: 'Nominal harus lebih dari 0.',
      );
      return;
    }

    final now = DateTime.now();
    final waktuPengingat = _calculateWaktuPengingat();
    final shouldSchedule = _pengingat != 'Tidak ada';

    // Determine initial status based on due date
    final BillStatus status;
    if (_selectedDate.isBefore(DateTime(now.year, now.month, now.day))) {
      status = BillStatus.overdue;
    } else if (_selectedDate
            .difference(DateTime(now.year, now.month, now.day))
            .inDays <=
        3) {
      status = BillStatus.pending;
    } else {
      status = BillStatus.upcoming;
    }

    final bill = BillEntity(
      id: _uuid.v4(),
      nama: nama,
      nominal: nominal,
      tanggalJatuhTempo: _selectedDate,
      waktuPengingat: waktuPengingat ?? _selectedDate,
      status: status,
      createdAt: now,
      updatedAt: now,
      syncStatus: false,
    );

    setState(() => _isLoading = true);

    try {
      final repository = await ref.read(billRepositoryProvider.future);
      final savedBill = await repository.addBill(bill);

      // Schedule reminder notification if applicable
      var reminderScheduled = false;
      if (shouldSchedule && savedBill.waktuPengingat.isAfter(DateTime.now())) {
        try {
          final localDatasource = await ref.read(
            billLocalDatasourceProvider.future,
          );

          // Fetch the bill model to get the Isar-assigned ID for notifications.
          // Retry once after a short delay if the first fetch returns null
          // (guards against a potential race condition with Isar indexing).
          var billModel = await localDatasource.getBillById(savedBill.id);
          if (billModel == null || billModel.isarId == null) {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            billModel = await localDatasource.getBillById(savedBill.id);
          }

          if (billModel != null && billModel.isarId != null) {
            await NotificationService().scheduleBillReminder(
              id: billModel.isarId!,
              title: 'Tagihan Mendatang',
              body:
                  '${savedBill.nama} - Rp ${CurrencyFormatter.format(savedBill.nominal ?? 0)} jatuh tempo ${DateFormatter.formatDate(savedBill.tanggalJatuhTempo)}',
              scheduledDate: savedBill.waktuPengingat,
              payload: savedBill.id,
            );
            reminderScheduled = true;
          }
        } catch (_) {
          reminderScheduled = false;
        }
      }

      if (mounted) {
        await FeedbackDialog.showSuccess<void>(
          context,
          title: 'Tagihan berhasil disimpan',
          message: reminderScheduled
              ? 'Pengingat tagihan sudah ditambahkan.'
              : 'Tagihan tersimpan. Pengingat sistem tidak aktif di perangkat ini.',
        );
      }
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          title: 'Gagal menyimpan tagihan',
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
                title: 'Tambah Tagihan',
                showBackButton: true,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      label: 'Nama Tagihan',
                      hint: 'Contoh: Netflix, Listrik, Kos',
                      controller: _namaController,
                      icon: Icons.receipt_long_outlined,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildNominalField(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDateField(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildPengingatField(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTipeToggle(),
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false,
  }) {
    return AppModernTextField(
      controller: controller,
      label: label,
      optionalText: isOptional ? '(opsional)' : null,
      hint: hint,
      prefixIcon: icon,
      keyboardType: keyboardType,
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
      label: 'Jatuh Tempo',
      value: _formattedDate,
      icon: Icons.calendar_today_outlined,
      onTap: _pickDate,
    );
  }

  Widget _buildPengingatField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengingat',
          style: TextStyle(
            color: AppColors.textSecondaryOf(context),
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColorOf(context)),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _pengingat,
              isExpanded: true,
              icon: Icon(
                Icons.expand_more,
                color: AppColors.textSecondaryOf(context),
              ),
              style: TextStyle(
                color: AppColors.textPrimaryOf(context),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              items: _pengingatOptions.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _pengingat = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipe Tagihan',
          style: TextStyle(
            color: AppColors.textSecondaryOf(context),
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 1.4,
          ),
        ),
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
                  label: 'Rutin',
                  isActive: _isRutin,
                  onTap: () => setState(() => _isRutin = true),
                ),
              ),
              Expanded(
                child: _buildToggleButton(
                  label: 'Sekali',
                  isActive: !_isRutin,
                  onTap: () => setState(() => _isRutin = false),
                ),
              ),
            ],
          ),
        ),
      ],
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
                    'Simpan Tagihan',
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
