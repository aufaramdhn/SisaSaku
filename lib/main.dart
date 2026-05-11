import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/supabase_config.dart';
import 'core/providers/isar_provider.dart';
import 'core/services/notification_service.dart';
import 'core/widgets/sync_lifecycle_listener.dart';
import 'routes/app_router.dart';
import 'features/category/data/models/category_model.dart';
import 'features/transaction/data/models/transaction_model.dart';
import 'features/bill/data/models/bill_model.dart';

// Initialize Isar
Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open([
    CategoryModelSchema,
    TransactionModelSchema,
    BillModelSchema,
  ], directory: dir.path);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }
  final isar = await initIsar();
  await NotificationService().init();
  await NotificationService().requestPermissions();

  runApp(
    ProviderScope(
      overrides: [
        // Override isarProvider with actual instance
        isarProvider.overrideWithValue(isar),
      ],
      child: const MyApp(),
    ),
  );

  // Listen to notification taps and navigate accordingly
  NotificationService().onNotificationTap.listen((payload) {
    if (payload != null && payload.isNotEmpty) {
      AppRouter.router.push('/bill/$payload');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SyncLifecycleListener(
      child: MaterialApp.router(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
