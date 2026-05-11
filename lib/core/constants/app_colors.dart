import 'package:flutter/material.dart';

/// Design tokens for SisaSaku
abstract class AppColors {
  // Primary Colors
  static const int _primaryValue = 0xFF1D9E75;
  static const primaryColor = Color(_primaryValue);
  static const primaryLight = Color(0xFFE1F5EE);
  static const primaryDark = Color(0xFF0F6E56);

  // Warning Colors
  static const warningColor = Color(0xFFEF9F27);
  static const warningLight = Color(0xFFFAEEDA);
  static const warningDark = Color(0xFF854F0B);

  // Danger Colors
  static const dangerColor = Color(0xFFE24B4A);
  static const dangerLight = Color(0xFFFCEBEB);
  static const dangerDark = Color(0xFFA32D2D);

  // Success Colors
  static const successColor = Color(0xFF3B6D11);
  static const successLight = Color(0xFFEAF3DE);
  static const successDark = Color(0xFF0F6E56);

  // Tertiary Colors
  static const tertiary = Color(0xFFAF262A);
  static const tertiaryLight = Color(0xFFFFDAD7);

  // Neutral Colors
  static const bgPrimary = Color(0xFFFFFFFF);
  static const bgSecondary = Color(0xFFF4F6F8);
  static const bgTertiary = Color(0xFFEAECEF);
  static const surfaceVariant = Color(0xFFDEE4DE);

  static const textPrimary = Color(0xFF1A1D23);
  static const textSecondary = Color(0xFF6B7280);
  static const borderColor = Color(0xFFE5E7EB);

  // Dark mode
  static const darkBgPrimary = Color(0xFF1A1D23);
  static const darkBgSecondary = Color(0xFF22262E);
  static const darkBgTertiary = Color(0xFF2C313C);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF9CA3AF);
}
