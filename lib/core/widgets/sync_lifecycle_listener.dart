import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/services/notification_service.dart';
import 'package:sisasaku/core/providers/sync_provider.dart';
import 'package:sisasaku/features/auth/presentation/providers/auth_providers.dart';
import 'package:sisasaku/features/security/presentation/providers/security_provider.dart';

class SyncLifecycleListener extends ConsumerStatefulWidget {
  final Widget child;

  const SyncLifecycleListener({super.key, required this.child});

  @override
  ConsumerState<SyncLifecycleListener> createState() =>
      _SyncLifecycleListenerState();
}

class _SyncLifecycleListenerState extends ConsumerState<SyncLifecycleListener>
    with WidgetsBindingObserver {
  ProviderSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Trigger lock screen on initial app launch if PIN is enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerLockScreenIfNeeded();
    });

    _authSubscription = ref.listenManual<AuthState>(authStateProvider, (
      previous,
      next,
    ) {
      if (previous?.status == AuthStatus.authenticated &&
          next.status == AuthStatus.unauthenticated) {
        NotificationService().deactivateRemoteTokenInCloud(
          userId: previous?.user?.id,
        );
      }
      if (next.status == AuthStatus.authenticated) {
        final syncService = ref.read(syncServiceProvider);
        syncService.syncAll();
        NotificationService().syncRemoteTokenToCloud();
        ref
            .read(profileSyncServiceProvider)
            .syncProfileForCurrentUser(next.user!.id);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _triggerLockScreenIfNeeded();
    _syncOnResume();
  }

  void _triggerLockScreenIfNeeded() {
    final security = ref.read(securityProvider);
    if (!security.pinEnabled) return;
    ref.read(securityProvider.notifier).showLockScreen();
  }

  Future<void> _syncOnResume() async {
    final authState = ref.read(authStateProvider);
    if (authState.status != AuthStatus.authenticated) return;

    final syncService = ref.read(syncServiceProvider);
    if (!await syncService.shouldSync()) return;
    await syncService.syncAll();
    await NotificationService().syncRemoteTokenToCloud();
    await ref
        .read(profileSyncServiceProvider)
        .syncProfileForCurrentUser(authState.user!.id);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
