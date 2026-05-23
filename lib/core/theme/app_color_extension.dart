import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Theme extension that provides semantic color tokens for light/dark mode.
///
/// Usage: `context.colors.bgPrimary`
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgTertiary;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final Color surfaceVariant;

  const AppColorsExtension({
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgTertiary,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    required this.surfaceVariant,
  });

  /// Light mode color set.
  static const light = AppColorsExtension(
    bgPrimary: AppColors.bgPrimary,
    bgSecondary: AppColors.bgSecondary,
    bgTertiary: AppColors.bgTertiary,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    borderColor: AppColors.borderColor,
    surfaceVariant: AppColors.surfaceVariant,
  );

  /// Dark mode color set.
  static const dark = AppColorsExtension(
    bgPrimary: AppColors.darkBgPrimary,
    bgSecondary: AppColors.darkBgSecondary,
    bgTertiary: AppColors.darkBgTertiary,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    borderColor: Color(0xFF3A3F4B),
    surfaceVariant: Color(0xFF2C313C),
  );

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? bgPrimary,
    Color? bgSecondary,
    Color? bgTertiary,
    Color? textPrimary,
    Color? textSecondary,
    Color? borderColor,
    Color? surfaceVariant,
  }) {
    return AppColorsExtension(
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgTertiary: bgTertiary ?? this.bgTertiary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      borderColor: borderColor ?? this.borderColor,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgTertiary: Color.lerp(bgTertiary, other.bgTertiary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
    );
  }
}

/// Convenience extension on [BuildContext] for quick access to theme colors.
///
/// Example:
/// ```dart
/// Container(color: context.colors.bgPrimary)
/// ```
extension AppColorsExtensionContext on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}
