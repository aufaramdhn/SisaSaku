import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/providers/isar_provider.dart';
import 'package:sisasaku/core/providers/supabase_provider.dart';
import 'package:sisasaku/core/services/profile_sync_service.dart';
import 'package:sisasaku/core/services/sync_service.dart';

final syncStatusRefreshProvider = StateProvider<int>((ref) => 0);

final syncServiceProvider = Provider<SyncService>((ref) {
  final isar = ref.read(isarProvider);
  final client = ref.read(supabaseClientProvider);
  return SyncService(isar: isar, client: client);
});

final profileSyncServiceProvider = Provider<ProfileSyncService>((ref) {
  final client = ref.read(supabaseClientProvider);
  return ProfileSyncService(client: client);
});

final syncStatusProvider = FutureProvider<SyncStatusSnapshot>((ref) async {
  ref.watch(syncStatusRefreshProvider);
  final service = ref.read(syncServiceProvider);
  return service.getStatusSnapshot();
});
