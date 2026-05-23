import 'package:flutter/material.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'quick_action_grid.dart';

Future<void> showQuickActionMoreSheet(
  BuildContext context,
  List<QuickActionItem> items,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, ctrl) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.bgPrimaryOf(context),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x14000000), blurRadius: 10),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderColorOf(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Lainnya',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: GridView.builder(
                    controller: ctrl,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisSpacing: AppSpacing.sm,
                        ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final it = items[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            it.onTap();
                          },
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: it.backgroundColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  it.icon,
                                  color: it.iconColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                it.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimaryOf(context),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
