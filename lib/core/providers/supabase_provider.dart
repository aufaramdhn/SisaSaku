import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sisasaku/core/constants/supabase_config.dart';

final supabaseClientProvider = Provider<SupabaseClient?>(
  (ref) => SupabaseConfig.isConfigured ? Supabase.instance.client : null,
);
