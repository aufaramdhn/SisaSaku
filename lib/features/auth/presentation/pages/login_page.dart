import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/core/constants/app_colors.dart';
import 'package:sisasaku/core/constants/app_spacing.dart';
import 'package:sisasaku/core/constants/app_strings.dart';
import 'package:sisasaku/features/auth/presentation/providers/auth_providers.dart';
import 'package:sisasaku/routes/app_router.dart';
import 'package:sisasaku/shared/widgets/ui/ui.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isGuest = authState.status == AuthStatus.unauthenticated;

    return Scaffold(
      backgroundColor: AppColors.bgSecondaryOf(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.login,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Masuk untuk mengaktifkan sinkronisasi cloud dan backup data.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryOf(context),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: isGuest
                      ? () async {
                          try {
                            await ref
                                .read(authStateProvider.notifier)
                                .signInWithGoogle();
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
                  icon: const Icon(Icons.g_mobiledata_rounded),
                  label: Text(
                    AppStrings.loginGoogle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.bgPrimaryOf(context),
                    foregroundColor: AppColors.textPrimaryOf(context),
                    side: BorderSide(
                      color: AppColors.borderColorOf(context).withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRouter.dashboard),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: const Text(
                    'Lanjutkan sebagai Tamu',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Dengan masuk, Anda menyetujui kebijakan privasi dan syarat layanan.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryOf(context),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
