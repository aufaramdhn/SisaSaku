import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/providers/isar_provider.dart';
import 'package:sisasaku/core/providers/supabase_provider.dart';
import 'package:sisasaku/core/services/sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final isar = ref.read(isarProvider);
  final client = ref.read(supabaseClientProvider);
  return SyncService(isar: isar, client: client);
});
