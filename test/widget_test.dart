import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisasaku/main.dart';

void main() {
  testWidgets('MyApp builds with ProviderScope', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
