// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abonekontrol/features/subscriptions/providers/subscription_providers.dart';

import 'package:abonekontrol/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We override the subscriptionListProvider to return an empty list
    // so we don't need to initialize Hive.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionListProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const SubZeroApp(),
      ),
    );

    // Verify that the dashboard title is present.
    expect(find.text('Logic Test Phase'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
