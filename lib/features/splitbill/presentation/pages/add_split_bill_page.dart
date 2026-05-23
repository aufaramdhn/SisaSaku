import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/features/splitbill/domain/entities/split_bill_entity.dart';
import 'package:sisasaku/features/splitbill/presentation/providers/split_bill_provider.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';
import 'package:uuid/uuid.dart';

class AddSplitBillPage extends ConsumerStatefulWidget {
  const AddSplitBillPage({super.key});

  @override
  ConsumerState<AddSplitBillPage> createState() => _AddSplitBillPageState();
}

class _AddSplitBillPageState extends ConsumerState<AddSplitBillPage> {
  final _titleController = TextEditingController();
  final _totalController = TextEditingController();
  bool _isEqualSplit = true;
  final List<_ParticipantField> _participants = [
    _ParticipantField(name: 'Andi'),
    _ParticipantField(name: 'Budi'),
    _ParticipantField(name: 'Citra'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _totalController.dispose();
    for (final p in _participants) {
      p.nameController.dispose();
      p.controller.dispose();
    }
    super.dispose();
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
                    'Tambah Bagi Rata',
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
                    _buildLabel('Judul'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Makan Bareng',
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
                    _buildLabel('Total Nominal'),
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
                            controller: _totalController,
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
                              label: 'Sama Rata',
                              isActive: _isEqualSplit,
                              onTap: () => setState(() => _isEqualSplit = true),
                            ),
                          ),
                          Expanded(
                            child: _buildToggleButton(
                              label: 'Custom',
                              isActive: !_isEqualSplit,
                              onTap: () =>
                                  setState(() => _isEqualSplit = false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('Peserta'),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _participants.add(
                                _ParticipantField(
                                  name: 'Orang ${_participants.length + 1}',
                                ),
                              );
                            });
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Tambah'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...List.generate(_participants.length, (index) {
                      final p = _participants[index];
                      return _ParticipantInput(
                        participant: p,
                        showAmount: !_isEqualSplit,
                        canRemove: _participants.length > 2,
                        onRemove: () {
                          setState(() {
                            _participants.removeAt(index);
                          });
                        },
                      );
                    }),
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
                    onTap: _saveSplitBill,
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

  Future<void> _saveSplitBill() async {
    final title = _titleController.text.trim();
    final total = double.tryParse(_totalController.text.trim());
    final names = _participants
        .map((p) => p.nameController.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (title.isEmpty || total == null || total <= 0 || names.length < 2) {
      await FeedbackDialog.showError<void>(
        context,
        title: 'Data belum lengkap',
        message: 'Isi judul, total nominal, dan minimal 2 peserta.',
        actionLabel: 'Oke',
      );
      return;
    }

    final amounts = _isEqualSplit
        ? List<double>.filled(names.length, total / names.length)
        : _participants.take(names.length).map((p) {
            return double.tryParse(p.controller.text.trim()) ?? 0;
          }).toList();

    final customTotal = amounts.fold<double>(0, (sum, amount) => sum + amount);
    if (!_isEqualSplit &&
        (amounts.any((amount) => amount <= 0) ||
            (customTotal - total).abs() > 0.01)) {
      await FeedbackDialog.showError<void>(
        context,
        title: 'Nominal belum sesuai',
        message:
            'Isi nominal tiap peserta dan pastikan totalnya sama dengan total tagihan.',
        actionLabel: 'Oke',
      );
      return;
    }

    final now = DateTime.now();
    final splitBill = SplitBillEntity(
      id: const Uuid().v4(),
      title: title,
      total: total,
      isEqualSplit: _isEqualSplit,
      participantNames: names,
      participantAmounts: amounts,
      paidParticipantNames: const [],
      isSettled: false,
      createdAt: now,
      updatedAt: now,
      syncStatus: false,
    );

    try {
      await ref.read(addSplitBillProvider(splitBill).future);
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
}

class _ParticipantField {
  String name;
  late final TextEditingController nameController;
  final TextEditingController controller;

  _ParticipantField({required this.name, TextEditingController? controller})
    : controller = controller ?? TextEditingController() {
    nameController = TextEditingController(text: name);
  }
}

class _ParticipantInput extends StatelessWidget {
  final _ParticipantField participant;
  final bool showAmount;
  final bool canRemove;
  final VoidCallback onRemove;

  const _ParticipantInput({
    required this.participant,
    required this.showAmount,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.bgSecondaryOf(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              color: AppColors.textSecondaryOf(context),
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: participant.nameController,
                  decoration: _inputDecoration(context, 'Nama'),
                ),
                if (showAmount) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: participant.controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: _inputDecoration(
                      context,
                      'Nominal per peserta',
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (canRemove)
            IconButton(
              onPressed: onRemove,
              icon: Icon(
                Icons.close,
                color: AppColors.textSecondaryOf(context),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 14),
      filled: true,
      fillColor: AppColors.bgSecondaryOf(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
    );
  }
}
