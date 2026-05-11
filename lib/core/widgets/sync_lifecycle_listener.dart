import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/providers/sync_provider.dart';
import 'package:sisasaku/features/auth/presentation/providers/auth_providers.dart';

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

    _authSubscription = ref.listenManual<AuthState>(
      authStateProvider,
      (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        final syncService = ref.read(syncServiceProvider);
        syncService.syncAll();
      }
      },
    );
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
    _syncOnResume();
  }

  Future<void> _syncOnResume() async {
    final authState = ref.read(authStateProvider);
    if (authState.status != AuthStatus.authenticated) return;

    final syncService = ref.read(syncServiceProvider);
    if (!await syncService.shouldSync()) return;
    await syncService.syncAll();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
