import 'dart:ui';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/constants/app_strings.dart';
import 'package:sisasaku/core/providers/isar_provider.dart';
import 'package:sisasaku/core/providers/theme_provider.dart';
import 'package:sisasaku/core/services/dummy_data_service.dart';
import 'package:sisasaku/core/theme/app_color_extension.dart';
import 'package:sisasaku/features/auth/presentation/providers/auth_providers.dart';
import 'package:sisasaku/features/security/presentation/pages/pin_setup_page.dart';
import 'package:sisasaku/features/security/presentation/pages/pin_verify_page.dart';
import 'package:sisasaku/features/security/presentation/providers/security_provider.dart';
import 'package:sisasaku/features/settings/presentation/providers/profile_provider.dart';
import 'package:sisasaku/routes/app_router.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _generateDummyData(BuildContext context, WidgetRef ref) async {
    try {
      final isar = ref.read(isarProvider);
      await DummyDataService.generateSampleData(isar);
      if (context.mounted) {
        await FeedbackDialog.showSuccess<void>(
          context,
          title: 'Data dummy berhasil dibuat',
          message: 'Data contoh sudah ditambahkan ke aplikasi.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        await FeedbackDialog.showError<void>(
          context,
          title: 'Gagal membuat data dummy',
          message: e.toString(),
          actionLabel: 'Oke',
        );
      }
    }
  }

  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    final confirmed = await FeedbackDialog.showConfirm(
      context,
      title: 'Hapus Semua Data',
      message:
          'Semua data transaksi, tagihan, dan kategori akan dihapus. Tindakan ini tidak dapat dibatalkan.',
      actionLabel: 'Hapus',
    );

    if (!confirmed) return;

    try {
      final isar = ref.read(isarProvider);
      await DummyDataService.clearAllData(isar);
      if (context.mounted) {
        await FeedbackDialog.showSuccess<void>(
          context,
          title: 'Semua data berhasil dihapus',
          message: 'Aplikasi sudah kembali ke kondisi kosong.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        await FeedbackDialog.showError<void>(
          context,
          title: 'Gagal menghapus data',
          message: e.toString(),
          actionLabel: 'Oke',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final profileAsync = ref.watch(profileViewProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isGuest = authState.status == AuthStatus.unauthenticated;

    return Scaffold(
      backgroundColor: context.colors.bgSecondary,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.decorativeBlurOf(context, alpha: 0.4),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFDAD7).withValues(alpha: 0.3),
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
                  _buildStickyHeader(context),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppStrings.pengaturan,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  profileAsync.when(
                    loading: () => const _ProfileSectionSkeleton(),
                    error: (_, _) => const _ProfileSectionSkeleton(),
                    data: (profile) => _buildProfileSection(
                      context,
                      profile,
                      () async {
                        try {
                          await ref.read(authStateProvider.notifier).signOut();
                          ref.read(profileRefreshProvider.notifier).state++;
                        } catch (_) {
                          if (!context.mounted) return;
                          await FeedbackDialog.showError<void>(
                            context,
                            title: 'Gagal keluar',
                            message: 'Coba lagi beberapa saat lagi.',
                            actionLabel: 'Oke',
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (isGuest) _buildWarningCard() else _buildActiveCard(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildMenuGroup(
                    context,
                    title: 'Profil',
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline,
                        iconBgColor: AppColors.primaryLight,
                        iconColor: AppColors.primaryColor,
                        label: isGuest ? 'Profil Lokal' : 'Edit Profil',
                        onTap: () => context.push(AppRouter.editProfile),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildMenuGroup(
                    context,
                    title: 'Preferensi',
                    items: [
                      _MenuItem(
                        icon: Icons.category_outlined,
                        iconBgColor: context.colors.surfaceVariant,
                        label: 'Kelola Kategori',
                        onTap: () => context.push(AppRouter.category),
                      ),
                      _MenuItem(
                        icon: Icons.notifications_active_outlined,
                        iconBgColor: context.colors.surfaceVariant,
                        iconColor: null,
                        label: 'Notifikasi',
                        onTap: () => context.push(AppRouter.notifications),
                      ),
                      _MenuItem(
                        icon: Icons.palette_outlined,
                        iconBgColor: context.colors.surfaceVariant,
                        label: 'Tema',
                        trailing: Text(
                          _themeModeLabel(themeMode),
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        onTap: () => _showThemePicker(context, ref, themeMode),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSecuritySection(context, ref),
                  const SizedBox(height: AppSpacing.xl),
                  _buildMenuGroup(
                    context,
                    title: 'Data & Ekspor',
                    items: [
                      _MenuItem(
                        icon: Icons.description_outlined,
                        iconBgColor: AppColors.successLight,
                        iconColor: AppColors.successColor,
                        label: AppStrings.eksporCSV,
                        onTap: () => context.push(AppRouter.exportData),
                      ),
                      _MenuItem(
                        icon: Icons.picture_as_pdf_outlined,
                        iconBgColor: AppColors.dangerLight,
                        iconColor: AppColors.dangerDark,
                        label: AppStrings.eksporPDF,
                        onTap: () => context.push(AppRouter.exportData),
                      ),
                    ],
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _buildMenuGroup(
                      context,
                      title: 'Developer',
                      items: [
                        _MenuItem(
                          icon: Icons.data_array_outlined,
                          iconBgColor: AppColors.primaryLight,
                          iconColor: AppColors.primaryColor,
                          label: 'Generate Data Dummy',
                          onTap: () => _generateDummyData(context, ref),
                        ),
                        _MenuItem(
                          icon: Icons.delete_forever_outlined,
                          iconBgColor: AppColors.dangerLight,
                          iconColor: AppColors.dangerColor,
                          label: 'Hapus Semua Data',
                          onTap: () => _clearAllData(context, ref),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl2),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'SisaSaku',
                          style: TextStyle(
                            color: AppColors.textSecondaryOf(context),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'v1.0.0',
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
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primaryColor,
            ),
          ),
          AppHeaderIconButton(
            icon: Icons.notifications_none_outlined,
            onPressed: () => context.push(AppRouter.notifications),
            color: context.colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    ProfileViewData profile,
    VoidCallback onSignOut,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              _SettingsProfileAvatar(
                initials: profile.initials,
                avatarPath: profile.avatarPath,
                avatarUrl: profile.avatarPath == null
                    ? profile.avatarUrl
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                    if (profile.email != null && !profile.isGuest) ...[
                      const SizedBox(height: 2),
                      Text(
                        profile.email!,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.bgTertiary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        profile.statusLabel,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 9,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.push(AppRouter.editProfile),
                icon: const Icon(Icons.edit_outlined),
                color: context.colors.textSecondary,
                style: IconButton.styleFrom(
                  backgroundColor: context.colors.bgSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: InkWell(
                onTap: () => context.push(AppRouter.cloudBackup),
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        profile.backupLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!profile.isGuest) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSignOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.textSecondary,
                  side: BorderSide(
                    color: context.colors.borderColor.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                child: const Text(
                  AppStrings.logout,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: const Border(
          left: BorderSide(color: AppColors.warningColor, width: 3),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_off, color: AppColors.warningDark, size: 18),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Backup belum aktif',
                  style: TextStyle(
                    color: AppColors.warningDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Data Anda hanya tersimpan di perangkat ini. Login untuk mencadangkan.',
                  style: TextStyle(
                    color: AppColors.warningDark.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: const Border(
          left: BorderSide(color: AppColors.successColor, width: 3),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_done, color: AppColors.successColor, size: 18),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Backup aktif',
                  style: TextStyle(
                    color: AppColors.successColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Data Anda tersinkronisasi dengan cloud.',
                  style: TextStyle(
                    color: AppColors.successColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            'KEAMANAN',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w400,
              fontSize: 11,
              height: 1.4,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.colors.bgPrimary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Column(
              children: [
                // Kunci PIN toggle
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handlePinToggle(context, ref, securityState.pinEnabled),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              color: AppColors.primaryColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Kunci PIN',
                              style: TextStyle(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                          Switch(
                            value: securityState.pinEnabled,
                            onChanged: (value) =>
                                _handlePinToggle(context, ref, securityState.pinEnabled),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(height: 1, indent: 56, color: context.colors.borderColor),
                // Biometrik toggle
                Opacity(
                  opacity: securityState.pinEnabled ? 1.0 : 0.5,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: securityState.pinEnabled
                          ? () => _handleBiometricToggle(context, ref, securityState.biometricEnabled)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: context.colors.surfaceVariant,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.fingerprint,
                                color: context.colors.textSecondary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'Biometrik',
                                style: TextStyle(
                                  color: context.colors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            Switch(
                              value: securityState.biometricEnabled,
                              onChanged: securityState.pinEnabled
                                  ? (value) => _handleBiometricToggle(
                                      context, ref, securityState.biometricEnabled)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Ubah PIN (visible only when PIN is enabled)
                if (securityState.pinEnabled) ...[
                  Divider(height: 1, indent: 56, color: context.colors.borderColor),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleChangePin(context, ref),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: context.colors.surfaceVariant,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.pin_outlined,
                                color: context.colors.textSecondary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'Ubah PIN',
                                style: TextStyle(
                                  color: context.colors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: context.colors.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePinToggle(BuildContext context, WidgetRef ref, bool currentlyEnabled) async {
    if (!currentlyEnabled) {
      // Enable PIN → navigate to PinSetupPage
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const PinSetupPage()),
      );
    } else {
      // Disable PIN → verify current PIN first
      final verified = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const PinVerifyPage()),
      );
      if (verified == true) {
        await ref.read(securityProvider.notifier).clearPinStateAfterVerification();
      }
    }
  }

  Future<void> _handleBiometricToggle(BuildContext context, WidgetRef ref, bool currentlyEnabled) async {
    if (!currentlyEnabled) {
      final success = await ref.read(securityProvider.notifier).enableBiometric();
      if (!success && context.mounted) {
        await FeedbackDialog.showError<void>(
          context,
          title: 'Biometrik tidak tersedia',
          message: 'Biometrik tidak tersedia di perangkat ini.',
          actionLabel: 'Oke',
        );
      }
    } else {
      await ref.read(securityProvider.notifier).disableBiometric();
    }
  }

  Future<void> _handleChangePin(BuildContext context, WidgetRef ref) async {
    // First verify current PIN
    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PinVerifyPage()),
    );
    if (verified == true && context.mounted) {
      // Then navigate to PIN setup for new PIN
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const PinSetupPage()),
      );
    }
  }

  Widget _buildMenuGroup(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w400,
              fontSize: 11,
              height: 1.4,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.colors.bgPrimary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Column(
              children: List.generate(items.length * 2 - 1, (index) {
                if (index.isOdd) {
                  return Divider(
                    height: 1,
                    indent: 56,
                    color: context.colors.borderColor,
                  );
                }
                final item = items[index ~/ 2];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: item.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: item.iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              color: item.iconColor ?? context.colors.textSecondary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                          item.trailing ??
                              Icon(
                                Icons.chevron_right,
                                color: context.colors.textSecondary,
                                size: 20,
                              ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.bgPrimary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Pilih Tema',
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tema akan langsung diterapkan ke seluruh aplikasi.',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ThemeOption(
                  title: 'Terang',
                  subtitle: 'Tampilan cerah untuk penggunaan harian',
                  icon: Icons.light_mode_outlined,
                  selected: currentMode == ThemeMode.light,
                  onTap: () async {
                    await ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.light);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _ThemeOption(
                  title: 'Gelap',
                  subtitle: 'Lebih nyaman untuk malam hari',
                  icon: Icons.dark_mode_outlined,
                  selected: currentMode == ThemeMode.dark,
                  onTap: () async {
                    await ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.dark);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _ThemeOption(
                  title: 'Sistem',
                  subtitle: 'Mengikuti pengaturan perangkat',
                  icon: Icons.phone_android_outlined,
                  selected: currentMode == ThemeMode.system,
                  onTap: () async {
                    await ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.system);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.dark => 'Gelap',
      ThemeMode.system => 'Sistem',
      ThemeMode.light => 'Terang',
    };
  }
}

class _ProfileSectionSkeleton extends StatelessWidget {
  const _ProfileSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 148,
      decoration: BoxDecoration(
        color: context.colors.bgPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}

class _SettingsProfileAvatar extends StatelessWidget {
  final String initials;
  final String? avatarPath;
  final String? avatarUrl;

  const _SettingsProfileAvatar({
    required this.initials,
    required this.avatarPath,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = _buildImageProvider();
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: imageProvider == null
            ? Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    height: 1.2,
                  ),
                ),
              )
            : Image(
                image: imageProvider,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        height: 1.2,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  ImageProvider<Object>? _buildImageProvider() {
    if (avatarPath != null && avatarPath!.isNotEmpty) {
      return FileImage(File(avatarPath!));
    }
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return NetworkImage(avatarUrl!);
    }
    return null;
  }
}

class _MenuItem {
  final IconData icon;
  final Color iconBgColor;
  final Color? iconColor;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.iconBgColor,
    this.iconColor,
    required this.label,
    this.trailing,
    required this.onTap,
  });
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? AppColors.primaryColor : context.colors.borderColor,
              width: selected ? 1.5 : 1,
            ),
            color: selected
                ? AppColors.decorativeBlurOf(context, alpha: 0.45)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: context.colors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: selected
                      ? AppColors.primaryColor
                      : context.colors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off_outlined,
                color: selected
                    ? AppColors.primaryColor
                    : context.colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
