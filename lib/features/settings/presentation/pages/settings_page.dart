import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/constants/app_strings.dart';
import 'package:sisasaku/core/providers/isar_provider.dart';
import 'package:sisasaku/core/services/dummy_data_service.dart';
import 'package:sisasaku/features/auth/presentation/providers/auth_providers.dart';
import 'package:sisasaku/routes/app_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _generateDummyData(BuildContext context, WidgetRef ref) async {
    try {
      final isar = ref.read(isarProvider);
      await DummyDataService.generateSampleData(isar);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data dummy berhasil dibuat')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat data dummy: $e')),
        );
      }
    }
  }

  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Data'),
        content: const Text(
          'Semua data transaksi, tagihan, dan kategori akan dihapus. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.dangerColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final isar = ref.read(isarProvider);
      await DummyDataService.clearAllData(isar);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua data berhasil dihapus')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isGuest = authState.status == AuthStatus.unauthenticated;

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
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
                  color: AppColors.primaryLight.withValues(alpha: 0.4),
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
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildProfileSection(
                    context,
                    authState,
                    isGuest,
                    () async {
                      try {
                        await ref.read(authStateProvider.notifier).signOut();
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal keluar. Coba lagi.'),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (isGuest) _buildWarningCard() else _buildActiveCard(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildMenuGroup(
                    title: 'Preferensi',
                    items: [
                      _MenuItem(
                        icon: Icons.category_outlined,
                        iconBgColor: AppColors.surfaceVariant,
                        label: 'Kelola Kategori',
                        onTap: () => context.push(AppRouter.category),
                      ),
                      _MenuItem(
                        icon: Icons.account_balance_wallet_outlined,
                        iconBgColor: AppColors.surfaceVariant,
                        label: 'Anggaran',
                        onTap: () => context.push(AppRouter.budget),
                      ),
                      _MenuItem(
                        icon: Icons.handshake_outlined,
                        iconBgColor: AppColors.surfaceVariant,
                        label: 'Hutang & Piutang',
                        onTap: () => context.push(AppRouter.debt),
                      ),
                      _MenuItem(
                        icon: Icons.notifications_active_outlined,
                        iconBgColor: AppColors.surfaceVariant,
                        label: 'Notifikasi',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.palette_outlined,
                        iconBgColor: AppColors.surfaceVariant,
                        label: 'Tema',
                        trailing: const Text(
                          'Terang',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildMenuGroup(
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
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'SisaSaku',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'v1.0.0',
                          style: TextStyle(
                            color: AppColors.textSecondary,
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
          const Icon(
            Icons.notifications_none_outlined,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    AuthState authState,
    bool isGuest,
    VoidCallback onSignOut,
  ) {
    final user = authState.user;
    final displayName = user?.name ?? user?.email ?? 'Pengguna';
    final email = user?.email;
    final initials = _getInitials(displayName, email);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
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
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                    if (email != null && !isGuest) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
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
                        color: AppColors.bgTertiary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        isGuest ? 'Mode Tamu' : 'Tersinkron',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 9,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
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
                        isGuest ? 'Login & Backup Cloud' : 'Kelola Backup Cloud',
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
          if (!isGuest) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSignOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(
                    color: AppColors.borderColor.withValues(alpha: 0.5),
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

  String _getInitials(String name, String? email) {
    final cleaned = name.trim();
    if (cleaned.isNotEmpty) {
      final parts = cleaned.split(' ').where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return cleaned.substring(0, 1).toUpperCase();
    }
    if (email != null && email.isNotEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    return 'SS';
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
          const Icon(
            Icons.cloud_off,
            color: AppColors.warningDark,
            size: 18,
          ),
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
          const Icon(
            Icons.cloud_done,
            color: AppColors.successColor,
            size: 18,
          ),
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

  Widget _buildMenuGroup({
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
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
              fontSize: 11,
              height: 1.4,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
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
                  return const Divider(
                    height: 1,
                    indent: 56,
                    color: AppColors.borderColor,
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
                              color: item.iconColor ?? AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              item.label,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                          item.trailing ??
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.textSecondary,
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
