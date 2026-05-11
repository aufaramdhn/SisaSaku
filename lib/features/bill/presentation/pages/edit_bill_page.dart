import 'package:flutter/material.dart';
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

class EditBillPage extends ConsumerStatefulWidget {
  final String billId;

  const EditBillPage({super.key, required this.billId});

  @override
  ConsumerState<EditBillPage> createState() => _EditBillPageState();
}

class _EditBillPageState extends ConsumerState<EditBillPage> {
  final _namaController = TextEditingController();
  final _nominalController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _pengingat = 'H-3';
  bool _isRutin = true;
  bool _isLoading = false;
  bool _isInitialized = false;
  int? _billIsarId;
  BillEntity? _initialBill;

  final _pengingatOptions = const ['H-1', 'H-3', 'H-7', 'Hari H', 'Tidak ada'];

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
    _namaController.dispose();
    _nominalController.dispose();
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

  String _resolvePengingat(BillEntity bill) {
    final diff = bill.tanggalJatuhTempo.difference(bill.waktuPengingat).inDays;
    if (diff == 1) return 'H-1';
    if (diff == 3) return 'H-3';
    if (diff == 7) return 'H-7';
    if (diff == 0) return 'Hari H';
    return 'Tidak ada';
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

  Future<void> _initializeForm(BillEntity bill) async {
    _initialBill = bill;
    _namaController.text = bill.nama;
    _nominalController.text = bill.nominal == null
        ? ''
        : CurrencyFormatter.format(bill.nominal!).replaceAll('Rp ', '');
    _selectedDate = bill.tanggalJatuhTempo;
    _pengingat = _resolvePengingat(bill);

    final localDatasource = await ref.read(billLocalDatasourceProvider.future);
    final billModel = await localDatasource.getBillById(bill.id);
    _billIsarId = billModel?.isarId;

    if (mounted) {
      setState(() {});
    }
  }

  void _ensureInitialized(BillEntity bill) {
    if (_isInitialized) return;
    _isInitialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeForm(bill);
    });
  }

  Future<void> _submit() async {
    final nama = _namaController.text.trim();
    if (nama.isEmpty) {
      _showSnackBar('Nama tagihan harus diisi');
      return;
    }

    final nominal = CurrencyFormatter.parse(_nominalController.text);
    if (nominal <= 0) {
      _showSnackBar('Nominal harus lebih dari 0');
      return;
    }

    if (_initialBill == null) return;

    final now = DateTime.now();
    final reminder = _calculateWaktuPengingat();
    final shouldSchedule = reminder != null;
    final waktuPengingat = reminder ?? _selectedDate;

    final BillStatus status;
    if (_initialBill!.status == BillStatus.paid) {
      status = BillStatus.paid;
    } else if (_selectedDate.isBefore(DateTime(now.year, now.month, now.day))) {
      status = BillStatus.overdue;
    } else if (_selectedDate
            .difference(DateTime(now.year, now.month, now.day))
            .inDays <=
        3) {
      status = BillStatus.pending;
    } else {
      status = BillStatus.upcoming;
    }

    final updated = _initialBill!.copyWith(
      nama: nama,
      nominal: nominal,
      tanggalJatuhTempo: _selectedDate,
      waktuPengingat: waktuPengingat,
      status: status,
      updatedAt: DateTime.now(),
      syncStatus: false,
    );

    setState(() => _isLoading = true);

    try {
      await ref.read(updateBillProvider(updated).future);

      if (_billIsarId != null) {
        await NotificationService().cancelBillReminder(_billIsarId!);
      }

      if (shouldSchedule &&
          status != BillStatus.paid &&
          waktuPengingat.isAfter(DateTime.now())) {
        final localDatasource = await ref.read(
          billLocalDatasourceProvider.future,
        );
        final billModel = await localDatasource.getBillById(updated.id);
        final isarId = billModel?.isarId ?? _billIsarId;
        if (isarId != null) {
          await NotificationService().scheduleBillReminder(
            id: isarId,
            title: 'Tagihan Mendatang',
            body:
                '${updated.nama} - Rp ${CurrencyFormatter.format(updated.nominal ?? 0)} jatuh tempo ${DateFormatter.formatDate(updated.tanggalJatuhTempo)}',
            scheduledDate: waktuPengingat,
            payload: updated.id,
          );
        }
      }

      if (mounted) {
        _showSnackBar('Tagihan berhasil diperbarui');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memperbarui tagihan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final billAsync = ref.watch(billByIdProvider(widget.billId));

    return billAsync.when(
      data: (bill) {
        if (bill == null) {
          return _buildMissingState();
        }
        _ensureInitialized(bill);
        return _buildScaffold();
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMissingState() {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tagihan tidak ditemukan'),
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

  Widget _buildScaffold() {
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
                    'Edit Tagihan',
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
                    _buildTextField(
                      label: 'Nominal',
                      hint: '0',
                      controller: _nominalController,
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                    ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.4,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
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
            hintText: hint,
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

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jatuh Tempo',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _formattedDate,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPengingatField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengingat',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _pengingat,
              isExpanded: true,
              icon: const Icon(
                Icons.expand_more,
                color: AppColors.textSecondary,
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
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
        const Text(
          'Tipe Tagihan',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.bgTertiary,
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
      color: isActive ? AppColors.bgPrimary : Colors.transparent,
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
                  : AppColors.textSecondary,
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
