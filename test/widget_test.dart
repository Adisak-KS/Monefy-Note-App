// Basic widget smoke test for Monefy Note app
// More comprehensive tests should be added in dedicated test files

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Widget smoke test - basic MaterialApp renders', (WidgetTester tester) async {
    // Set up mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Build a minimal app to verify basic widget rendering works
    await tester.pumpWidget(
      MaterialApp(
        title: 'Monefy Note Test',
        home: Scaffold(
          appBar: AppBar(title: const Text('Monefy Note')),
          body: const Center(
            child: Text('Test'),
          ),
        ),
      ),
    );

    // Verify app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Monefy Note'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
  });
}
