import 'package:flutter/material.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/constants/app_strings.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 64 + bottomInset,
          decoration: BoxDecoration(
            color: AppColors.bgPrimaryOf(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(22),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: bottomInset > 0 ? bottomInset : AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.home_rounded,
                    label: AppStrings.navBeranda,
                    isActive: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.assessment_outlined,
                    label: AppStrings.navLaporan,
                    isActive: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ),
                const SizedBox(width: 52),
                Expanded(
                  child: _NavItem(
                    icon: Icons.receipt_long_outlined,
                    label: AppStrings.navTagihan,
                    isActive: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.settings_outlined,
                    label: AppStrings.navPengaturan,
                    isActive: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: -26,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onTap(2),
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.30),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppColors.primaryColor
                  : AppColors.textSecondaryOf(context),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? AppColors.primaryColor
                    : AppColors.textSecondaryOf(context),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 10,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
