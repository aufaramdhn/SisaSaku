import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sisasaku/features/notification/presentation/pages/notification_data.dart';
import 'package:sisasaku/features/notification/presentation/pages/notification_page.dart';
import 'package:sisasaku/features/notification/presentation/providers/notification_provider.dart';

void main() {
  group('NotificationPage', () {
    Widget buildTestWidget({
      required List<Override> overrides,
    }) {
      return ProviderScope(
        overrides: overrides,
        child: const MaterialApp(
          home: NotificationPage(),
        ),
      );
    }

    testWidgets('renders notification items when data is available',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final notifications = [
        AppNotificationItem(
          id: 'bill-1',
          title: 'Listrik mendekati jatuh tempo',
          message: 'Jatuh tempo besok.',
          detail: 'Detail tagihan listrik.',
          createdAt: now,
          kind: NotificationKind.bill,
          isRead: false,
        ),
        AppNotificationItem(
          id: 'bill-2',
          title: 'Internet sudah melewati jatuh tempo',
          message: 'Tagihan perlu segera ditandai atau dibayar.',
          detail: 'Detail tagihan internet.',
          createdAt: now.subtract(const Duration(days: 2)),
          kind: NotificationKind.bill,
          isRead: true,
        ),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            notificationsProvider.overrideWith(
              (ref) async => notifications,
            ),
          ],
        ),
      );

      // Wait for the FutureProvider to resolve
      await tester.pumpAndSettle();

      // Verify the page title renders
      expect(find.text('Notifikasi'), findsOneWidget);

      // Verify notification items render
      expect(find.text('Listrik mendekati jatuh tempo'), findsOneWidget);
      expect(find.text('Jatuh tempo besok.'), findsOneWidget);
      expect(find.text('Internet sudah melewati jatuh tempo'), findsOneWidget);
      expect(
        find.text('Tagihan perlu segera ditandai atau dibayar.'),
        findsOneWidget,
      );

      // Verify unread count subtitle shows
      expect(
        find.text('1 notifikasi membutuhkan perhatian.'),
        findsOneWidget,
      );
    });

    testWidgets('renders empty state when no notifications exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            notificationsProvider.overrideWith(
              (ref) async => <AppNotificationItem>[],
            ),
          ],
        ),
      );

      // Wait for the FutureProvider to resolve
      await tester.pumpAndSettle();

      // Verify the page title renders
      expect(find.text('Notifikasi'), findsOneWidget);

      // Verify empty state message
      expect(
        find.text('Tidak ada tagihan yang perlu perhatian'),
        findsOneWidget,
      );

      // Verify subtitle shows no new notifications
      expect(
        find.text('Tidak ada notifikasi baru.'),
        findsOneWidget,
      );

      // Verify the empty state icon is shown
      expect(
        find.byIcon(Icons.notifications_none_rounded),
        findsOneWidget,
      );
    });

    testWidgets('shows loading indicator while data is loading',
        (WidgetTester tester) async {
      final completer = Completer<List<AppNotificationItem>>();

      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            notificationsProvider.overrideWith(
              (ref) => completer.future,
            ),
          ],
        ),
      );

      // Don't settle - check loading state
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to avoid pending timer issues
      completer.complete(<AppNotificationItem>[]);
      await tester.pumpAndSettle();
    });
  });
}
