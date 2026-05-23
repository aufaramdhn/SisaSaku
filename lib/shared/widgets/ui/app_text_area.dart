import 'package:flutter/material.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';

class AppTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int minLines;
  final int maxLines;
  final String? helperText;
  final bool showLabel;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const AppTextArea({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.minLines = 3,
    this.maxLines = 6,
    this.helperText,
    this.showLabel = true,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondaryOf(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          onChanged: onChanged,
          validator: validator,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimaryOf(context),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgSecondaryOf(context),
            hintText: hint,
            helperText: helperText,
            alignLabelWithHint: true,
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
