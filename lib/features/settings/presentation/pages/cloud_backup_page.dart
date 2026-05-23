import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/constants/app_strings.dart';
import 'package:sisasaku/core/constants/supabase_config.dart';
import 'package:sisasaku/core/providers/sync_provider.dart';
import 'package:sisasaku/core/services/local_preferences_service.dart';
import 'package:sisasaku/core/services/sync_service.dart';
import 'package:sisasaku/features/auth/presentation/providers/auth_providers.dart';
import 'package:sisasaku/features/settings/presentation/providers/profile_provider.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';

class CloudBackupPage extends ConsumerWidget {
  const CloudBackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final syncStatusAsync = ref.watch(syncStatusProvider);
    final isGuest = authState.status == AuthStatus.unauthenticated;

    return Scaffold(
      backgroundColor: AppColors.bgSecondaryOf(context),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withValues(alpha: 0.08),
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
                AppSpacing.xl2,
              ),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildStatusCard(context, isGuest, syncStatusAsync.valueOrNull),
                  const SizedBox(height: AppSpacing.xl),
                  _buildHeroSection(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildBenefitsList(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildActionButtons(
                    context,
                    ref,
                    isGuest,
                    syncStatusAsync.valueOrNull,
                  ),
                  _buildResolveConflictButton(
                    context,
                    ref,
                    isGuest,
                    syncStatusAsync.valueOrNull,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: AppColors.textSecondaryOf(context)),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.decorativeBlurOf(context, alpha: 0.5),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    bool isGuest,
    SyncStatusSnapshot? syncStatus,
  ) {
    final hasError = (syncStatus?.lastError?.isNotEmpty ?? false) && !isGuest;
    final hasPending = (syncStatus?.pendingChangeCount ?? 0) > 0 && !isGuest;
    final hasConflict = (syncStatus?.conflictCount ?? 0) > 0 && !isGuest;
    final isSynced =
        !isGuest &&
        !hasError &&
        !hasPending &&
        !hasConflict &&
        syncStatus?.lastSyncAt != null;
    final badgeLabel = isGuest
        ? 'Nonaktif'
        : hasError
        ? 'Bermasalah'
        : hasConflict
        ? 'Konflik'
        : hasPending
        ? 'Pending'
        : isSynced
        ? 'Tersinkron'
        : 'Aktif';
    final subtitle = isGuest
        ? 'Data tersimpan lokal'
        : hasError
        ? 'Sinkronisasi terakhir gagal. Periksa koneksi dan coba lagi.'
        : hasConflict
        ? '${syncStatus?.conflictCount ?? 0} data bentrok. Versi cloud yang lebih baru dipakai agar data tetap konsisten.'
        : hasPending
        ? '${syncStatus?.pendingChangeCount ?? 0} perubahan menunggu sinkronisasi.'
        : syncStatus?.lastSyncAt != null
        ? 'Terakhir sinkron ${_formatSyncTime(syncStatus!.lastSyncAt!)}'
        : 'Cloud backup siap digunakan.';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPrimaryOf(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderColorOf(context).withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.bgPrimaryOf(context),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isGuest
                  ? Icons.cloud_off
                  : hasError
                  ? Icons.cloud_off_outlined
                  : hasConflict
                  ? Icons.merge_type_rounded
                  : hasPending
                  ? Icons.cloud_upload_outlined
                  : Icons.cloud_done,
              color: isGuest
                  ? AppColors.textSecondaryOf(context)
                  : hasError
                  ? AppColors.dangerColor
                  : hasConflict
                  ? AppColors.warningDark
                  : hasPending
                  ? AppColors.warningDark
                  : AppColors.successColor,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Pencadangan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgTertiaryOf(context),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              badgeLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.decorativeBlurOf(context, alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.cloud_sync,
                color: AppColors.primaryColor,
                size: 48,
              ),
              Positioned(
                top: 16,
                right: 18,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.bgPrimaryOf(context),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 22,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.bgPrimaryOf(context),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Aman & Terhubung',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.1,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Masuk untuk mencadangkan data keuanganmu ke cloud. Nikmati akses mudah dari mana saja dan keamanan ekstra.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsList(BuildContext context) {
    final benefits = [
      _BenefitData(
        icon: Icons.verified_user,
        title: 'Keamanan Data Terjamin',
        description:
            'Data finansialmu aman di cloud, tidak akan hilang meski berganti perangkat.',
      ),
      _BenefitData(
        icon: Icons.devices,
        title: 'Akses Multi-Perangkat',
        description:
            'Pantau arus kas dan tagihanmu secara real-time dari HP, tablet, atau laptop.',
      ),
    ];

    return Column(
      children: benefits.map((b) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.bgPrimaryOf(context).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.borderColorOf(context).withValues(alpha: 0.3),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.decorativeBlurOf(context, alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      b.description,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    bool isGuest,
    SyncStatusSnapshot? syncStatus,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: isGuest
                ? () async {
                    if (!SupabaseConfig.isConfigured) {
                      await FeedbackDialog.showError<void>(
                        context,
                        title: 'Supabase belum dikonfigurasi',
                        message:
                            'Lengkapi konfigurasi Supabase sebelum memakai backup cloud.',
                        actionLabel: 'Oke',
                      );
                      return;
                    }

                    try {
                      await ref
                          .read(authStateProvider.notifier)
                          .signInWithGoogle();
                      ref.read(syncStatusRefreshProvider.notifier).state++;
                    } catch (_) {
                      if (!context.mounted) return;
                      await FeedbackDialog.showError<void>(
                        context,
                        title: 'Login gagal',
                        message: 'Coba lagi beberapa saat lagi.',
                        actionLabel: 'Oke',
                      );
                    }
                  }
                : null,
            icon: _GoogleIcon(),
            label: Text(
              'Lanjutkan dengan Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.bgPrimaryOf(context),
              side: BorderSide(
                color: AppColors.borderColorOf(context).withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ),
        if (!isGuest) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: syncStatus?.isSyncing == true
                  ? null
                  : () async {
                      try {
                        await ref.read(syncServiceProvider).syncAll();
                        final user = ref.read(authStateProvider).user;
                        if (user != null) {
                          await ref
                              .read(profileSyncServiceProvider)
                              .syncProfileForCurrentUser(user.id);
                          ref.read(profileRefreshProvider.notifier).state++;
                        }
                        ref.read(syncStatusRefreshProvider.notifier).state++;
                        if (!context.mounted) return;
                        await FeedbackDialog.showSuccess<void>(
                          context,
                          title: 'Sinkronisasi selesai',
                          message: 'Data lokal dan cloud sudah diperbarui.',
                        );
                      } catch (_) {
                        if (!context.mounted) return;
                        await FeedbackDialog.showError<void>(
                          context,
                          title: 'Gagal sinkronisasi',
                          message: 'Coba lagi beberapa saat lagi.',
                          actionLabel: 'Oke',
                        );
                      }
                    },
              icon: const Icon(Icons.sync, size: 20),
              label: Text(
                syncStatus?.isSyncing == true
                    ? 'Menyinkronkan...'
                    : 'Sinkronkan Sekarang',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: AppColors.primaryColor.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatSyncTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildResolveConflictButton(
    BuildContext context,
    WidgetRef ref,
    bool isGuest,
    SyncStatusSnapshot? syncStatus,
  ) {
    final hasConflict = (syncStatus?.conflictCount ?? 0) > 0 && !isGuest;
    if (!hasConflict) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: () async {
            try {
              await LocalPreferencesService.clearAllSyncConflicts();
              await ref.read(syncServiceProvider).syncAll();
              ref.read(syncStatusRefreshProvider.notifier).state++;
              if (!context.mounted) return;
              await FeedbackDialog.showSuccess<void>(
                context,
                title: 'Konflik diselesaikan',
                message: 'Semua konflik sinkronisasi telah dibersihkan.',
              );
            } catch (_) {
              if (!context.mounted) return;
              await FeedbackDialog.showError<void>(
                context,
                title: 'Gagal menyelesaikan konflik',
                message: 'Coba lagi beberapa saat lagi.',
                actionLabel: 'Oke',
              );
            }
          },
          icon: const Icon(Icons.merge_type_rounded, size: 20),
          label: const Text(
            'Selesaikan Konflik',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.warningDark,
            side: const BorderSide(color: AppColors.warningDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitData {
  final IconData icon;
  final String title;
  final String description;

  _BenefitData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path1 = Path()
      ..moveTo(size.width * 0.94, size.height * 0.51)
      ..cubicTo(
        size.width * 0.94,
        size.height * 0.48,
        size.width * 0.94,
        size.height * 0.45,
        size.width * 0.93,
        size.height * 0.42,
      )
      ..lineTo(size.width * 0.5, size.height * 0.42)
      ..lineTo(size.width * 0.5, size.height * 0.59)
      ..lineTo(size.width * 0.75, size.height * 0.59)
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.65,
        size.width * 0.7,
        size.height * 0.7,
        size.width * 0.65,
        size.height * 0.73,
      )
      ..lineTo(size.width * 0.65, size.height * 0.85)
      ..lineTo(size.width * 0.8, size.height * 0.85)
      ..cubicTo(
        size.width * 0.89,
        size.height * 0.77,
        size.width * 0.94,
        size.height * 0.65,
        size.width * 0.94,
        size.height * 0.51,
      )
      ..close();

    final path2 = Path()
      ..moveTo(size.width * 0.5, size.height * 0.96)
      ..cubicTo(
        size.width * 0.62,
        size.height * 0.96,
        size.width * 0.73,
        size.height * 0.92,
        size.width * 0.8,
        size.height * 0.85,
      )
      ..lineTo(size.width * 0.65, size.height * 0.73)
      ..cubicTo(
        size.width * 0.61,
        size.height * 0.76,
        size.width * 0.56,
        size.height * 0.78,
        size.width * 0.5,
        size.height * 0.78,
      )
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.78,
        size.width * 0.28,
        size.height * 0.7,
        size.width * 0.24,
        size.height * 0.59,
      )
      ..lineTo(size.width * 0.09, size.height * 0.59)
      ..lineTo(size.width * 0.09, size.height * 0.71)
      ..cubicTo(
        size.width * 0.17,
        size.height * 0.86,
        size.width * 0.32,
        size.height * 0.96,
        size.width * 0.5,
        size.height * 0.96,
      )
      ..close();

    final path3 = Path()
      ..moveTo(size.width * 0.24, size.height * 0.59)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.56,
        size.width * 0.21,
        size.height * 0.53,
        size.width * 0.21,
        size.height * 0.5,
      )
      ..cubicTo(
        size.width * 0.21,
        size.height * 0.47,
        size.width * 0.22,
        size.height * 0.44,
        size.width * 0.24,
        size.height * 0.41,
      )
      ..lineTo(size.width * 0.24, size.height * 0.29)
      ..lineTo(size.width * 0.09, size.height * 0.29)
      ..cubicTo(
        size.width * 0.03,
        size.height * 0.35,
        0,
        size.height * 0.42,
        0,
        size.height * 0.5,
      )
      ..cubicTo(
        0,
        size.height * 0.58,
        size.width * 0.03,
        size.height * 0.65,
        size.width * 0.09,
        size.height * 0.71,
      )
      ..lineTo(size.width * 0.24, size.height * 0.59)
      ..close();

    final path4 = Path()
      ..moveTo(size.width * 0.5, size.height * 0.22)
      ..cubicTo(
        size.width * 0.57,
        size.height * 0.22,
        size.width * 0.63,
        size.height * 0.25,
        size.width * 0.67,
        size.height * 0.29,
      )
      ..lineTo(size.width * 0.81, size.height * 0.15)
      ..cubicTo(
        size.width * 0.73,
        size.height * 0.08,
        size.width * 0.62,
        size.height * 0.04,
        size.width * 0.5,
        size.height * 0.04,
      )
      ..cubicTo(
        size.width * 0.32,
        size.height * 0.04,
        size.width * 0.17,
        size.height * 0.14,
        size.width * 0.09,
        size.height * 0.29,
      )
      ..lineTo(size.width * 0.24, size.height * 0.41)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.3,
        size.width * 0.38,
        size.height * 0.22,
        size.width * 0.5,
        size.height * 0.22,
      )
      ..close();

    canvas.drawPath(path1, Paint()..color = const Color(0xFF4285F4));
    canvas.drawPath(path2, Paint()..color = const Color(0xFF34A853));
    canvas.drawPath(path3, Paint()..color = const Color(0xFFFBBC05));
    canvas.drawPath(path4, Paint()..color = const Color(0xFFEA4335));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
