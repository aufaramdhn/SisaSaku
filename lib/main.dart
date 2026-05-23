import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/providers/theme_provider.dart';
import 'core/constants/supabase_config.dart';
import 'core/providers/isar_provider.dart';
import 'core/services/notification_service.dart';
import 'core/widgets/sync_lifecycle_listener.dart';
import 'features/security/domain/models/security_state.dart';
import 'features/security/presentation/pages/lock_screen.dart';
import 'features/security/presentation/providers/security_provider.dart';
import 'routes/app_router.dart';
import 'features/category/data/models/category_model.dart';
import 'features/transaction/data/models/transaction_model.dart';
import 'features/bill/data/models/bill_model.dart';
import 'features/budget/data/models/budget_model.dart';
import 'features/debt/data/models/debt_model.dart';
import 'features/splitbill/data/models/split_bill_model.dart';

// Initialize Isar
Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open([
    CategoryModelSchema,
    TransactionModelSchema,
    BillModelSchema,
    BudgetModelSchema,
    DebtModelSchema,
    SplitBillModelSchema,
  ], directory: dir.path);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  // Don't throw in release mode — just skip cloud features if not configured
  try {
    SupabaseConfig.validateOrThrow();
  } catch (e) {
    debugPrint('Supabase config validation: $e');
  }

  await _tryInitializeFirebase();

  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
    } catch (e) {
      debugPrint('Supabase init failed: $e');
    }
  }
  final isar = await initIsar();
  await NotificationService().init();
  await NotificationService().requestPermissions();
  await NotificationService().rescheduleAllBillReminders(isar);

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
  NotificationService().onNotificationTap.listen((route) {
    if (route != null && route.isNotEmpty) {
      AppRouter.router.push(route);
    }
  });
}

Future<void> _tryInitializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final securityState = ref.watch(securityProvider);

    final app = MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );

    // If lock screen is not visible, just return the app directly
    if (securityState.lockScreenStatus != LockScreenStatus.visible) {
      return SyncLifecycleListener(child: app);
    }

    // Show lock screen overlay on top of the app
    return SyncLifecycleListener(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            app,
            MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: const LockScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
