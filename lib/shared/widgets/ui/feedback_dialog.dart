import 'package:flutter/material.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';

class FeedbackDialog {
  FeedbackDialog._();

  static Future<T?> showSuccess<T>(
    BuildContext context, {
    required String title,
    String? message,
    String actionLabel = 'Selesai',
    VoidCallback? onAction,
  }) {
    return _show<T>(
      context,
      title: title,
      message: message,
      icon: Icons.check_circle,
      iconBg: AppColors.primaryLight,
      iconColor: AppColors.primaryColor,
      actionLabel: actionLabel,
      actionColor: AppColors.primaryColor,
      onAction: onAction,
    );
  }

  static Future<T?> showError<T>(
    BuildContext context, {
    required String title,
    String? message,
    String actionLabel = 'Coba Lagi',
    String? cancelLabel,
    VoidCallback? onAction,
    VoidCallback? onCancel,
  }) {
    return _show<T>(
      context,
      title: title,
      message: message,
      icon: Icons.error_outline,
      iconBg: AppColors.dangerLight,
      iconColor: AppColors.dangerDark,
      actionLabel: actionLabel,
      actionColor: AppColors.dangerColor,
      cancelLabel: cancelLabel,
      onAction: onAction,
      onCancel: onCancel,
    );
  }

  static Future<T?> showComingSoon<T>(
    BuildContext context, {
    required String title,
    String? message,
    String actionLabel = 'Tutup',
    VoidCallback? onAction,
  }) {
    return _show<T>(
      context,
      title: title,
      message: message,
      icon: Icons.construction,
      iconBg: AppColors.bgTertiaryOf(context),
      iconColor: AppColors.textSecondaryOf(context),
      actionLabel: actionLabel,
      actionColor: AppColors.textPrimaryOf(context),
      onAction: onAction,
    );
  }

  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    String? message,
    String actionLabel = 'Lanjutkan',
    String cancelLabel = 'Batal',
    VoidCallback? onAction,
    VoidCallback? onCancel,
  }) async {
    final confirmed = await _show<bool>(
      context,
      title: title,
      message: message,
      icon: Icons.warning_amber_rounded,
      iconBg: AppColors.dangerLight,
      iconColor: AppColors.dangerDark,
      actionLabel: actionLabel,
      actionColor: AppColors.dangerColor,
      cancelLabel: cancelLabel,
      onAction: onAction,
      onCancel: onCancel,
      actionResult: true,
      cancelResult: false,
    );

    return confirmed ?? false;
  }

  static Future<T?> _show<T>(
    BuildContext context, {
    required String title,
    String? message,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String actionLabel,
    required Color actionColor,
    String? cancelLabel,
    VoidCallback? onAction,
    VoidCallback? onCancel,
    T? actionResult,
    T? cancelResult,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.bgPrimaryOf(ctx),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 44),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryOf(ctx),
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondaryOf(ctx),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                if (cancelLabel != null)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(cancelResult);
                            if (onCancel != null) onCancel();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondaryOf(ctx),
                            side: BorderSide(
                              color: AppColors.borderColorOf(ctx),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                          ),
                          child: Text(cancelLabel),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(actionResult);
                            if (onAction != null) onAction();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: actionColor,
                            foregroundColor:
                                actionColor.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                          ),
                          child: Text(actionLabel),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(actionResult);
                        if (onAction != null) onAction();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionColor,
                        foregroundColor: actionColor.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(actionLabel),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
