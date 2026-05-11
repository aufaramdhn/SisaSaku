import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/constants/app_strings.dart';
import 'package:sisasaku/core/constants/supabase_config.dart';
import 'package:sisasaku/core/providers/sync_provider.dart';
import 'package:sisasaku/features/auth/presentation/providers/auth_providers.dart';

class CloudBackupPage extends ConsumerWidget {
  const CloudBackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isGuest = authState.status == AuthStatus.unauthenticated;

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
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
                  _buildStatusCard(isGuest),
                  const SizedBox(height: AppSpacing.xl),
                  _buildHeroSection(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildBenefitsList(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildActionButtons(context, ref, isGuest),
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
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.5),
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

  Widget _buildStatusCard(bool isGuest) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.bgPrimary,
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
              isGuest ? Icons.cloud_off : Icons.cloud_done,
              color: isGuest ? AppColors.textSecondary : AppColors.successColor,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Pencadangan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isGuest ? 'Data tersimpan lokal' : 'Data tersinkronisasi',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: AppColors.textSecondary,
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
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              isGuest ? 'Nonaktif' : 'Aktif',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.5),
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
                  decoration: const BoxDecoration(
                    color: AppColors.bgPrimary,
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
                  decoration: const BoxDecoration(
                    color: AppColors.bgPrimary,
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Masuk untuk mencadangkan data keuanganmu ke cloud. Nikmati akses mudah dari mana saja dan keamanan ekstra.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsList() {
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
            color: AppColors.bgPrimary.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.3),
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
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      b.description,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: AppColors.textSecondary,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Supabase belum dikonfigurasi.'),
                        ),
                      );
                      return;
                    }

                    try {
                      await ref
                          .read(authStateProvider.notifier)
                          .signInWithGoogle();
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login gagal. Coba lagi.')),
                      );
                    }
                  }
                : null,
            icon: _GoogleIcon(),
            label: const Text(
              'Lanjutkan dengan Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.bgPrimary,
              side: BorderSide(
                color: AppColors.borderColor.withValues(alpha: 0.5),
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
              onPressed: () async {
                try {
                  await ref.read(syncServiceProvider).syncAll();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sinkronisasi selesai.')),
                  );
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal sinkronisasi. Coba lagi.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.sync, size: 20),
              label: const Text(
                'Sinkronkan Sekarang',
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
