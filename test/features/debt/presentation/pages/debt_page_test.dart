import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/theme/app_theme.dart';
import 'package:sisasaku/features/debt/domain/entities/debt_entity.dart';
import 'package:sisasaku/features/debt/presentation/pages/debt_page.dart';
import 'package:sisasaku/features/debt/presentation/providers/debt_provider.dart';

void main() {
  late List<DebtEntity> mockDebts;

  setUp(() {
    final now = DateTime.now();
    mockDebts = [
      DebtEntity(
        id: 'debt-1',
        person: 'Budi',
        amount: 100000,
        date: now,
        notes: 'Pinjam makan',
        type: 'i_owe',
        isSettled: false,
        createdAt: now,
        updatedAt: now,
        syncStatus: true,
      ),
      DebtEntity(
        id: 'debt-2',
        person: 'Ani',
        amount: 200000,
        date: now,
        notes: 'Bayar tiket',
        type: 'they_owe',
        isSettled: false,
        createdAt: now,
        updatedAt: now,
        syncStatus: true,
      ),
    ];
  });

  group('DebtPage - Settlement Loading Guard', () {
    testWidgets('rapid double-tap only triggers one settlement call',
        (tester) async {
      // Use a completer that never completes to keep the settlement in-flight
      final completer = Completer<DebtEntity>();
      int callCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            debtsProvider.overrideWith((ref) => Stream.value(mockDebts)),
            deleteDebtProvider.overrideWith((ref, id) async {}),
            updateDebtSettlementProvider.overrideWith((ref, params) async {
              callCount++;
              return completer.future;
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DebtPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the first debt card (Budi - i_owe filter is default)
      final budiCard = find.text('Budi');
      expect(budiCard, findsOneWidget);

      // Find the InkWell wrapping the debt card for Budi
      final inkWell = find.ancestor(
        of: budiCard,
        matching: find.byType(InkWell),
      );
      expect(inkWell, findsOneWidget);

      // Tap once - should trigger settlement
      await tester.tap(inkWell.first);
      await tester.pump();

      // Tap again immediately - should be guarded
      await tester.tap(inkWell.first);
      await tester.pump();

      // Only one call should have been made due to the loading guard
      expect(callCount, 1);
    });

    testWidgets('loading indicator appears during settlement', (tester) async {
      final completer = Completer<DebtEntity>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            debtsProvider.overrideWith((ref) => Stream.value(mockDebts)),
            deleteDebtProvider.overrideWith((ref, id) async {}),
            updateDebtSettlementProvider.overrideWith((ref, params) async {
              return completer.future;
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DebtPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify no loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Tap the debt card to trigger settlement
      final budiCard = find.text('Budi');
      final inkWell = find.ancestor(
        of: budiCard,
        matching: find.byType(InkWell),
      );
      await tester.tap(inkWell.first);
      await tester.pump();

      // Now a CircularProgressIndicator should appear (the small one in the card)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Also verify the "Memproses..." text appears
      expect(find.text('Memproses...'), findsOneWidget);

      // Complete the settlement to clean up
      completer.complete(mockDebts[0].copyWith(isSettled: true));
      await tester.pumpAndSettle();
    });

    testWidgets('settlement completes and removes loading state',
        (tester) async {
      final completer = Completer<DebtEntity>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            debtsProvider.overrideWith((ref) => Stream.value(mockDebts)),
            deleteDebtProvider.overrideWith((ref, id) async {}),
            updateDebtSettlementProvider.overrideWith((ref, params) async {
              return completer.future;
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DebtPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap to start settlement
      final budiCard = find.text('Budi');
      final inkWell = find.ancestor(
        of: budiCard,
        matching: find.byType(InkWell),
      );
      await tester.tap(inkWell.first);
      await tester.pump();

      // Verify loading state
      expect(find.text('Memproses...'), findsOneWidget);

      // Complete the settlement
      completer.complete(mockDebts[0].copyWith(isSettled: true));
      await tester.pumpAndSettle();

      // Loading indicator should be gone
      expect(find.text('Memproses...'), findsNothing);
    });
  });
}
