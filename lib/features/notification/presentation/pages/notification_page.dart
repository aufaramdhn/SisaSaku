import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/features/notification/presentation/pages/notification_data.dart';
import 'package:sisasaku/features/notification/presentation/providers/notification_provider.dart';
import 'package:sisasaku/routes/app_router.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondaryOf(context),
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
              child: Container(
                width: 280,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.decorativeBlurOf(context, alpha: 0.45),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Gagal memuat notifikasi: $err')),
              data: (notifications) {
                final unreadCount = notifications
                    .where((n) => !n.isRead)
                    .length;
                final todayItems = _todayItems(notifications);
                final olderItems = _olderItems(notifications);

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppPageHeader(
                        title: 'Notifikasi',
                        subtitle: unreadCount == 0
                            ? 'Tidak ada notifikasi baru.'
                            : '$unreadCount notifikasi membutuhkan perhatian.',
                        showBackButton: true,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _NotificationSummary(unreadCount: unreadCount),
                      const SizedBox(height: AppSpacing.xl),
                      if (notifications.isEmpty)
                        const _EmptyNotifications()
                      else ...[
                        _buildSection(context, ref, 'Hari ini', todayItems),
                        const SizedBox(height: AppSpacing.lg),
                        _buildSection(context, ref, 'Sebelumnya', olderItems),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<AppNotificationItem> _todayItems(
    List<AppNotificationItem> notifications,
  ) {
    final now = DateTime.now();
    return notifications.where((item) {
      return item.createdAt.year == now.year &&
          item.createdAt.month == now.month &&
          item.createdAt.day == now.day;
    }).toList();
  }

  List<AppNotificationItem> _olderItems(
    List<AppNotificationItem> notifications,
  ) {
    final now = DateTime.now();
    return notifications.where((item) {
      return item.createdAt.year != now.year ||
          item.createdAt.month != now.month ||
          item.createdAt.day != now.day;
    }).toList();
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<AppNotificationItem> items,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimaryOf(context),
            fontWeight: FontWeight.w800,
            fontSize: 16,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _NotificationCard(
              item: item,
              onTap: () async {
                await ref.read(markNotificationReadProvider(item.id).future);
                if (!context.mounted) return;
                context.push(
                  AppRouter.notificationDetail.replaceAll(':id', item.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.bgPrimaryOf(context),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textSecondaryOf(context),
            size: 42,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Tidak ada tagihan yang perlu perhatian',
            style: TextStyle(
              color: AppColors.textSecondaryOf(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationSummary extends StatelessWidget {
  final int unreadCount;

  const _NotificationSummary({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgPrimaryOf(context),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderColorOf(context).withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan Notifikasi',
                  style: TextStyle(
                    color: AppColors.textPrimaryOf(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unreadCount == 0
                      ? 'Semua tagihan aman'
                      : '$unreadCount tagihan membutuhkan perhatian',
                  style: TextStyle(
                    color: AppColors.textSecondaryOf(context),
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotificationItem item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgPrimaryOf(context),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: item.isRead
                  ? AppColors.borderColorOf(context).withValues(alpha: 0.35)
                  : AppColors.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: 21),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimaryOf(context),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondaryOf(context),
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatRelativeTime(item.createdAt),
                      style: TextStyle(
                        color: AppColors.textSecondaryOf(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondaryOf(context),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}
