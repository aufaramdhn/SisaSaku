import 'package:flutter/material.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';

class AppSelect<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? helperText;
  final bool showLabel;
  final Widget? prefixIcon;
  final bool isExpanded;

  const AppSelect({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.helperText,
    this.showLabel = true,
    this.prefixIcon,
    this.isExpanded = true,
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
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          isExpanded: isExpanded,
          icon: const Icon(Icons.expand_more_rounded),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}
