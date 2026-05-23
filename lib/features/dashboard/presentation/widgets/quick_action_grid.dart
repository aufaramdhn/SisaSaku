import 'package:flutter/material.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';

class QuickActionItem {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  QuickActionItem({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });
}

class QuickActionGrid extends StatelessWidget {
  final List<QuickActionItem> items;
  final int maxVisible;
  final VoidCallback? onShowMore;

  const QuickActionGrid({
    super.key,
    required this.items,
    this.maxVisible = 7,
    this.onShowMore,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.95,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: items.length > maxVisible ? maxVisible : items.length,
      itemBuilder: (context, index) {
        final isMoreTile = items.length > maxVisible && index == maxVisible - 1;
        final item = items[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isMoreTile ? (onShowMore ?? item.onTap) : item.onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.bgPrimaryOf(context),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isMoreTile
                          ? AppColors.bgTertiaryOf(context)
                          : item.backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isMoreTile ? Icons.grid_view : item.icon,
                      color: isMoreTile
                          ? AppColors.textSecondaryOf(context)
                          : item.iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    isMoreTile ? 'Lainnya' : item.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimaryOf(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
