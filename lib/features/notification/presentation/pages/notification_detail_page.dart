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

class NotificationDetailPage extends ConsumerStatefulWidget {
  final String notificationId;

  const NotificationDetailPage({super.key, required this.notificationId});

  @override
  ConsumerState<NotificationDetailPage> createState() =>
      _NotificationDetailPageState();
}

class _NotificationDetailPageState
    extends ConsumerState<NotificationDetailPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () =>
          ref.read(markNotificationReadProvider(widget.notificationId).future),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return notificationsAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.bgSecondaryOf(context),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AppColors.bgSecondaryOf(context),
        body: Center(child: Text('Gagal memuat detail: $err')),
      ),
      data: (notifications) {
        AppNotificationItem? item;
        for (final notification in notifications) {
          if (notification.id == widget.notificationId) {
            item = notification;
            break;
          }
        }

        if (item == null) {
          return Scaffold(
            backgroundColor: AppColors.bgSecondaryOf(context),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const AppPageHeader(
                      title: 'Detail Notifikasi',
                      showBackButton: true,
                    ),
                    const Spacer(),
                    const Text('Notifikasi tidak ditemukan'),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Kembali'),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        }
        final notification = item;

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
                      color: notification.color.withValues(alpha: 0.14),
                    ),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppPageHeader(
                        title: 'Detail Notifikasi',
                        showBackButton: true,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _DetailCard(item: notification),
                      const SizedBox(height: AppSpacing.xl),
                      if (notification.billId != null)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: () => context.push(
                              AppRouter.billDetail.replaceAll(
                                ':id',
                                notification.billId!,
                              ),
                            ),
                            icon: const Icon(Icons.receipt_long_outlined),
                            label: const Text('Lihat Tagihan'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailCard extends StatelessWidget {
  final AppNotificationItem item;

  const _DetailCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 34),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimaryOf(context),
              fontWeight: FontWeight.w800,
              fontSize: 20,
              height: 1.25,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _formatTime(item.createdAt),
            style: TextStyle(
              color: AppColors.textSecondaryOf(context),
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, color: AppColors.borderColorOf(context)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            item.detail,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondaryOf(context),
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
