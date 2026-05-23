import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/providers/sync_provider.dart';
import 'package:sisasaku/core/services/local_preferences_service.dart';
import 'package:sisasaku/features/settings/presentation/providers/profile_provider.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _didLoadInitialValue = false;
  bool _isSaving = false;
  bool _isPickingPhoto = false;
  String? _selectedAvatarPath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    Future.microtask(_loadInitialProfile);
  }

  Future<void> _loadInitialProfile() async {
    final profile = await ref.read(profileViewProvider.future);
    if (!mounted) return;

    _nameController.text = profile.displayName;
    _emailController.text = profile.email ?? '';
    setState(() {
      _selectedAvatarPath = profile.avatarPath;
      _didLoadInitialValue = true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileViewProvider);

    return profileAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.bgSecondaryOf(context),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.bgSecondaryOf(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Gagal memuat profil: $error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondaryOf(context),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
      data: (profile) {
        final effectiveAvatarPath = _selectedAvatarPath ?? profile.avatarPath;
        final nameText = _didLoadInitialValue
            ? _nameController.text
            : profile.displayName;
        final emailText = _didLoadInitialValue
            ? _emailController.text
            : profile.email;
        final initials = _getInitials(nameText, emailText);

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
                    width: 300,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.decorativeBlurOf(context, alpha: 0.45),
                    ),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: AppPageHeader(
                        title: profile.profileTitle,
                        showBackButton: true,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: AppSpacing.lg),
                            _ProfileAvatar(
                              initials: initials,
                              avatarPath: effectiveAvatarPath,
                              avatarUrl: effectiveAvatarPath == null
                                  ? profile.avatarUrl
                                  : null,
                              canChangePhoto: profile.canChangePhoto,
                              isBusy: _isPickingPhoto,
                              onChangePhoto: profile.canChangePhoto
                                  ? () => _pickProfilePhoto(profile)
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            AppModernTextField(
                              controller: _nameController,
                              label: 'Nama',
                              hint: 'Masukkan nama',
                              prefixIcon: Icons.person_outline,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (profile.isGuest)
                              AppModernTextField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'Masukkan email',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                optionalText: 'opsional',
                              )
                            else
                              _ReadOnlyInfoField(
                                label: 'Email Akun',
                                value: profile.email ?? '-',
                                icon: Icons.email_outlined,
                              ),
                            const SizedBox(height: AppSpacing.md),
                            _InfoCard(message: profile.infoMessage),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        MediaQuery.of(context).padding.bottom + AppSpacing.md,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _isSaving
                              ? null
                              : () => _saveProfile(profile),
                          child: Text(
                            _isSaving ? 'Menyimpan...' : 'Simpan Profil',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile(ProfileViewData profile) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      await FeedbackDialog.showError<void>(
        context,
        title: 'Nama belum diisi',
        message: 'Silakan isi nama profil terlebih dahulu.',
        actionLabel: 'Oke',
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await LocalPreferencesService.saveProfile(
        scope: profile.scope,
        name: name,
        email: profile.isGuest ? email : (profile.email ?? ''),
      );
      if (!profile.isGuest) {
        await ref
            .read(profileSyncServiceProvider)
            .syncLocalProfileToCloud(
              scope: profile.scope,
              displayName: name,
              email: profile.email ?? '',
              avatarPath: _selectedAvatarPath ?? profile.avatarPath,
            );
      }
      ref.read(profileRefreshProvider.notifier).state++;

      if (!mounted) return;
      await FeedbackDialog.showSuccess<void>(
        context,
        title: 'Profil tersimpan',
        message: profile.isGuest
            ? 'Profil lokal di perangkat ini berhasil diperbarui.'
            : 'Nama tampilan profil berhasil diperbarui di perangkat ini.',
      );
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      await FeedbackDialog.showError<void>(
        context,
        title: 'Gagal menyimpan profil',
        message: e.toString(),
        actionLabel: 'Oke',
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickProfilePhoto(ProfileViewData profile) async {
    setState(() => _isPickingPhoto = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 88,
      );

      if (picked == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory('${appDir.path}/profile_avatars');
      if (!await avatarDir.exists()) {
        await avatarDir.create(recursive: true);
      }

      final extension = _fileExtension(picked.path);
      final safeScope = profile.scope.replaceAll(
        RegExp(r'[^A-Za-z0-9_-]'),
        '_',
      );
      final targetPath = '${avatarDir.path}/avatar_$safeScope$extension';
      final existingPath = await LocalPreferencesService.getProfileAvatarPath(
        scope: profile.scope,
      );

      await File(picked.path).copy(targetPath);

      if (existingPath != null &&
          existingPath != targetPath &&
          await File(existingPath).exists()) {
        await File(existingPath).delete();
      }

      await LocalPreferencesService.setProfileAvatarPath(
        scope: profile.scope,
        path: targetPath,
      );
      if (!profile.isGuest) {
        await ref
            .read(profileSyncServiceProvider)
            .syncLocalProfileToCloud(
              scope: profile.scope,
              displayName: _nameController.text.trim().isEmpty
                  ? profile.displayName
                  : _nameController.text.trim(),
              email: profile.email ?? '',
              avatarPath: targetPath,
            );
      }

      ref.read(profileRefreshProvider.notifier).state++;
      if (!mounted) return;
      setState(() => _selectedAvatarPath = targetPath);
    } catch (e) {
      if (!mounted) return;
      await FeedbackDialog.showError<void>(
        context,
        title: 'Gagal memilih foto',
        message: e.toString(),
        actionLabel: 'Oke',
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingPhoto = false);
      }
    }
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
    final fallback = email?.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return fallback.substring(0, 1).toUpperCase();
    }
    return 'SS';
  }

  String _fileExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return '.jpg';
    }
    return path.substring(dotIndex);
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String initials;
  final String? avatarPath;
  final String? avatarUrl;
  final bool canChangePhoto;
  final bool isBusy;
  final VoidCallback? onChangePhoto;

  const _ProfileAvatar({
    required this.initials,
    required this.avatarPath,
    required this.avatarUrl,
    required this.canChangePhoto,
    required this.isBusy,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = _buildImageProvider();

    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.bgPrimaryOf(context), width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: imageProvider == null
                ? Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        height: 1.1,
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
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                            height: 1.1,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (canChangePhoto)
          TextButton.icon(
            onPressed: isBusy ? null : onChangePhoto,
            icon: Icon(
              isBusy ? Icons.hourglass_top_rounded : Icons.camera_alt_outlined,
              size: 18,
            ),
            label: Text(isBusy ? 'Memproses...' : 'Ganti Foto'),
          ),
      ],
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

class _ReadOnlyInfoField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReadOnlyInfoField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldLabel(label: label),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.bgSecondaryOf(context),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderColorOf(context)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondaryOf(context), size: 19),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textPrimaryOf(context),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String message;

  const _InfoCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.decorativeBlurOf(context, alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primaryColor,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textSecondaryOf(context),
                fontWeight: FontWeight.w400,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
