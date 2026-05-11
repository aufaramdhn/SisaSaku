import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/routes/app_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Pantau Tiap Rupiah Tanpa Ribet',
      description:
          'Catat pengeluaran dan pemasukan dengan cepat. SisaSaku bantu kamu mengelola keuangan harian dengan mudah.',
      illustration: const _Onboarding1Illustration(),
      blobs: _page1Blobs,
    ),
    _OnboardingData(
      title: 'Jangan Pernah Lupa Tagihan',
      description:
          'Catat tagihan rutinmu dan dapatkan pengingat sebelum jatuh tempo. Hidup tenang tanpa denda keterlambatan.',
      illustration: const _Onboarding2Illustration(),
      blobs: _page2Blobs,
    ),
    _OnboardingData(
      title: 'Aman & Selalu Sinkron',
      description:
          'Data finansialmu otomatis dicadangkan di cloud dengan sistem keamanan tingkat tinggi. Tenang dan pantau kapan saja.',
      illustration: const _Onboarding3Illustration(),
      blobs: _page3Blobs,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRouter.dashboard);
    }
  }

  void _skip() {
    context.go(AppRouter.dashboard);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingSlide(
                    data: page,
                    onSkip: _skip,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xl2,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryColor
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xl2),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: AppColors.primaryColor.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Mulai Sekarang'
                            : 'Lanjutkan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ─── Blob configurations per page ─── */

final List<_BlobConfig> _page1Blobs = [
  _BlobConfig(
    left: 30,
    top: 60,
    width: 280,
    height: 280,
    blur: 50,
    colors: [
      const Color(0xFF68DBAE).withValues(alpha: 0.45),
      const Color(0xFF86F8C9).withValues(alpha: 0.15),
      Colors.transparent,
    ],
  ),
  _BlobConfig(
    left: -40,
    top: 280,
    width: 240,
    height: 240,
    blur: 45,
    colors: [
      const Color(0xFFFCAA33).withValues(alpha: 0.35),
      const Color(0xFFFFDDB7).withValues(alpha: 0.1),
      Colors.transparent,
    ],
  ),
];

final List<_BlobConfig> _page2Blobs = [
  _BlobConfig(
    left: 180,
    top: 40,
    width: 260,
    height: 260,
    blur: 50,
    colors: [
      const Color(0xFFFCAA33).withValues(alpha: 0.45),
      const Color(0xFFFFB95D).withValues(alpha: 0.15),
      Colors.transparent,
    ],
  ),
  _BlobConfig(
    left: -20,
    top: 320,
    width: 220,
    height: 220,
    blur: 45,
    colors: [
      const Color(0xFF68DBAE).withValues(alpha: 0.3),
      const Color(0xFF86F8C9).withValues(alpha: 0.1),
      Colors.transparent,
    ],
  ),
];

final List<_BlobConfig> _page3Blobs = [
  _BlobConfig(
    left: -30,
    top: 80,
    width: 300,
    height: 300,
    blur: 55,
    colors: [
      const Color(0xFF68DBAE).withValues(alpha: 0.4),
      const Color(0xFF86F8C9).withValues(alpha: 0.15),
      Colors.transparent,
    ],
  ),
  _BlobConfig(
    left: 140,
    top: 300,
    width: 260,
    height: 260,
    blur: 50,
    colors: [
      const Color(0xFFD23F40).withValues(alpha: 0.25),
      const Color(0xFFFFDAD7).withValues(alpha: 0.1),
      Colors.transparent,
    ],
  ),
];

/* ─── Data models ─── */

class _OnboardingData {
  final String title;
  final String description;
  final Widget illustration;
  final List<_BlobConfig> blobs;

  _OnboardingData({
    required this.title,
    required this.description,
    required this.illustration,
    required this.blobs,
  });
}

class _BlobConfig {
  final double left;
  final double top;
  final double width;
  final double height;
  final double blur;
  final List<Color> colors;

  _BlobConfig({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.blur,
    required this.colors,
  });
}

/* ─── Slide ─── */

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingData data;
  final VoidCallback? onSkip;

  const _OnboardingSlide({
    required this.data,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _AtmosphericLayer(blobs: data.blobs),
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor.withValues(alpha: 0.8),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(child: data.illustration),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text(
                      data.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl2),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* ─── Atmospheric background ─── */

class _AtmosphericLayer extends StatelessWidget {
  final List<_BlobConfig> blobs;

  const _AtmosphericLayer({required this.blobs});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...blobs.map((blob) {
          return Positioned(
            left: blob.left,
            top: blob.top,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blob.blur, sigmaY: blob.blur),
              child: Container(
                width: blob.width,
                height: blob.height,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: blob.colors,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/* ─── Illustrations ─── */

class _Onboarding1Illustration extends StatelessWidget {
  const _Onboarding1Illustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withValues(alpha: 0.06),
            ),
          ),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withValues(alpha: 0.1),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: AppColors.primaryColor,
              size: 48,
            ),
          ),
          Positioned(
            top: 30,
            right: 30,
            child: _FloatingItem(
              icon: Icons.attach_money,
              color: AppColors.warningColor,
              bgColor: AppColors.warningLight,
              size: 44,
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            child: _FloatingItem(
              icon: Icons.trending_up,
              color: AppColors.successColor,
              bgColor: AppColors.successLight,
              size: 40,
            ),
          ),
          Positioned(
            top: 60,
            left: 30,
            child: _FloatingItem(
              icon: Icons.receipt_long,
              color: AppColors.dangerColor,
              bgColor: AppColors.dangerLight,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

class _Onboarding2Illustration extends StatelessWidget {
  const _Onboarding2Illustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.warningColor.withValues(alpha: 0.06),
            ),
          ),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.warningColor.withValues(alpha: 0.1),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.warningLight,
            ),
            child: const Icon(
              Icons.notifications_active,
              color: AppColors.warningDark,
              size: 48,
            ),
          ),
          Positioned(
            top: 20,
            left: 40,
            child: _FloatingItem(
              icon: Icons.calendar_month,
              color: AppColors.primaryColor,
              bgColor: AppColors.primaryLight,
              size: 40,
            ),
          ),
          Positioned(
            bottom: 40,
            right: 30,
            child: _FloatingItem(
              icon: Icons.paid,
              color: AppColors.successColor,
              bgColor: AppColors.successLight,
              size: 44,
            ),
          ),
          Positioned(
            top: 70,
            right: 20,
            child: _FloatingItem(
              icon: Icons.timer,
              color: AppColors.dangerColor,
              bgColor: AppColors.dangerLight,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

class _Onboarding3Illustration extends StatelessWidget {
  const _Onboarding3Illustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withValues(alpha: 0.06),
            ),
          ),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withValues(alpha: 0.1),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
            ),
            child: const Icon(
              Icons.cloud_sync,
              color: AppColors.primaryColor,
              size: 48,
            ),
          ),
          Positioned(
            top: 30,
            right: 30,
            child: _FloatingItem(
              icon: Icons.verified_user,
              color: AppColors.successColor,
              bgColor: AppColors.successLight,
              size: 44,
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            child: _FloatingItem(
              icon: Icons.devices,
              color: AppColors.primaryColor,
              bgColor: AppColors.primaryLight,
              size: 40,
            ),
          ),
          Positioned(
            top: 60,
            left: 30,
            child: _FloatingItem(
              icon: Icons.lock,
              color: AppColors.warningColor,
              bgColor: AppColors.warningLight,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final double size;

  const _FloatingItem({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
