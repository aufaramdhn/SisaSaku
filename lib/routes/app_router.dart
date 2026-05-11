import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sisasaku/features/analytics/presentation/pages/analytics_page.dart';
import 'package:sisasaku/features/bill/presentation/pages/add_bill_page.dart';
import 'package:sisasaku/features/bill/presentation/pages/bill_page.dart';
import 'package:sisasaku/features/bill/presentation/pages/edit_bill_page.dart';
import 'package:sisasaku/features/category/presentation/pages/add_category_page.dart';
import 'package:sisasaku/features/category/presentation/pages/category_page.dart';
import 'package:sisasaku/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sisasaku/features/auth/presentation/pages/login_page.dart';
import 'package:sisasaku/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sisasaku/features/onboarding/presentation/pages/splash_screen.dart';
import 'package:sisasaku/features/settings/presentation/pages/cloud_backup_page.dart';
import 'package:sisasaku/features/settings/presentation/pages/settings_page.dart';
import 'package:sisasaku/features/budget/presentation/pages/add_budget_page.dart';
import 'package:sisasaku/features/budget/presentation/pages/budget_page.dart';
import 'package:sisasaku/features/debt/presentation/pages/add_debt_page.dart';
import 'package:sisasaku/features/debt/presentation/pages/debt_page.dart';
import 'package:sisasaku/features/export/presentation/pages/export_page.dart';
import 'package:sisasaku/features/splitbill/presentation/pages/add_split_bill_page.dart';
import 'package:sisasaku/features/splitbill/presentation/pages/split_bill_detail_page.dart';
import 'package:sisasaku/features/splitbill/presentation/pages/split_bill_page.dart';
import 'package:sisasaku/features/transaction/presentation/pages/add_transaction_page.dart';
import 'package:sisasaku/features/transaction/presentation/pages/edit_transaction_page.dart';
import 'package:sisasaku/features/transaction/presentation/pages/transaction_detail_page.dart';
import 'package:sisasaku/features/transaction/presentation/pages/transaction_history_page.dart';
import 'package:sisasaku/shared/widgets/main_shell.dart';

/// Navigation routes configuration
class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/';
  static const String analytics = '/analytics';
  static const String bill = '/bill';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String category = '/category';
  static const String cloudBackup = '/cloud-backup';
  static const String addTransaction = '/add-transaction';
  static const String addBill = '/add-bill';
  static const String addCategory = '/add-category';
  static const String transactionHistory = '/transactions';
  static const String transactionDetail = '/transaction/:id';
  static const String editTransaction = '/transaction/:id/edit';
  static const String editBill = '/bill/:id/edit';
  static const String budget = '/budget';
  static const String addBudget = '/budget/add';
  static const String splitBill = '/split-bill';
  static const String addSplitBill = '/split-bill/add';
  static const String splitBillDetail = '/split-bill/:id';
  static const String exportData = '/export';
  static const String debt = '/debt';
  static const String addDebt = '/debt/add';

  static final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: dashboard,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: category,
        builder: (context, state) => const CategoryPage(),
      ),
      GoRoute(
        path: addCategory,
        builder: (context, state) => const AddCategoryPage(),
      ),
      GoRoute(
        path: cloudBackup,
        builder: (context, state) => const CloudBackupPage(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: addTransaction,
        builder: (context, state) => const AddTransactionPage(),
      ),
      GoRoute(
        path: transactionHistory,
        builder: (context, state) => const TransactionHistoryPage(),
      ),
      GoRoute(
        path: addBill,
        builder: (context, state) => const AddBillPage(),
      ),
      GoRoute(
        path: transactionDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TransactionDetailPage(transactionId: id);
        },
      ),
      GoRoute(
        path: editTransaction,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditTransactionPage(transactionId: id);
        },
      ),
      GoRoute(
        path: editBill,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditBillPage(billId: id);
        },
      ),
      GoRoute(
        path: budget,
        builder: (context, state) => const BudgetPage(),
      ),
      GoRoute(
        path: addBudget,
        builder: (context, state) => const AddBudgetPage(),
      ),
      GoRoute(
        path: splitBill,
        builder: (context, state) => const SplitBillPage(),
      ),
      GoRoute(
        path: addSplitBill,
        builder: (context, state) => const AddSplitBillPage(),
      ),
      GoRoute(
        path: splitBillDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SplitBillDetailPage(splitBillId: id);
        },
      ),
      GoRoute(
        path: exportData,
        builder: (context, state) => const ExportPage(),
      ),
      GoRoute(
        path: debt,
        builder: (context, state) => const DebtPage(),
      ),
      GoRoute(
        path: addDebt,
        builder: (context, state) => const AddDebtPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: dashboard,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: analytics,
            builder: (context, state) => const AnalyticsPage(),
          ),
          GoRoute(
            path: bill,
            builder: (context, state) => const BillPage(),
          ),
          GoRoute(
            path: settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
