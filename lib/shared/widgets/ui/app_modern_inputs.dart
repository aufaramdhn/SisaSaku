import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';

class AppFieldLabel extends StatelessWidget {
  final String label;
  final String? suffix;

  const AppFieldLabel({super.key, required this.label, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondaryOf(context),
            fontWeight: FontWeight.w600,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        if (suffix != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            suffix!,
            style: TextStyle(
              color: AppColors.textSecondaryOf(context).withValues(alpha: 0.65),
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class AppModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final String? optionalText;

  const AppModernTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.optionalText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldLabel(label: label, suffix: optionalText),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          minLines: maxLines == 1 ? 1 : null,
          style: TextStyle(
            color: AppColors.textPrimaryOf(context),
            fontWeight: FontWeight.w500,
            fontSize: 14,
            height: 1.45,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgSecondaryOf(context),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                    color: AppColors.textSecondaryOf(context),
                    size: 19,
                  ),
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondaryOf(context),
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            border: _border(AppColors.borderColorOf(context)),
            enabledBorder: _border(AppColors.borderColorOf(context)),
            focusedBorder: _border(AppColors.primaryColor, width: 1.4),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class AppMoneyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final List<TextInputFormatter>? inputFormatters;

  const AppMoneyField({
    super.key,
    required this.controller,
    required this.label,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldLabel(label: label),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.bgSecondaryOf(context),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderColorOf(context)),
          ),
          child: Row(
            children: [
              const Text(
                'Rp',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  inputFormatters: inputFormatters,
                  style: TextStyle(
                    color: AppColors.textPrimaryOf(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    height: 1.1,
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
        ),
      ],
    );
  }
}

class AppSelectableField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const AppSelectableField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldLabel(label: label),
        const SizedBox(height: AppSpacing.sm),
        Material(
          color: AppColors.bgSecondaryOf(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderColorOf(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.textSecondaryOf(context),
                    size: 19,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: AppColors.textPrimaryOf(context),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondaryOf(context),
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
