import 'package:flutter/material.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/utils/currency_formatter.dart';

class TransactionRow extends StatelessWidget {
  final String kategoriNama;
  final IconData kategoriIcon;
  final Color kategoriColor;
  final String waktu;
  final double nominal;
  final bool isIncome;
  final bool showDivider;
  final VoidCallback? onTap;

  const TransactionRow({
    super.key,
    required this.kategoriNama,
    required this.kategoriIcon,
    required this.kategoriColor,
    required this.waktu,
    required this.nominal,
    required this.isIncome,
    this.showDivider = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isIncome
        ? AppColors.primaryColor
        : AppColors.textPrimaryOf(context);
    final nominalText = isIncome
        ? '+${CurrencyFormatter.format(nominal)}'
        : '-${CurrencyFormatter.format(nominal)}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    bottom: BorderSide(
                      color: AppColors.borderColorOf(context),
                      width: 0.8,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kategoriColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(kategoriIcon, color: kategoriColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kategoriNama,
                      style: TextStyle(
                        color: AppColors.textPrimaryOf(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      waktu,
                      style: TextStyle(
                        color: AppColors.textSecondaryOf(context),
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                nominalText,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
