import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriveda_mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NutriVedaApp());

    // Verify that the login screen is displayed
    expect(find.text('NutriVeda'), findsOneWidget);
    expect(find.text('Dietitian App'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}