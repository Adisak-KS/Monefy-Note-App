// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monefy_note_app/main.dart';
import 'package:monefy_note_app/core/theme/theme_cubit.dart';
import 'package:monefy_note_app/core/theme/color_cubit.dart';
import 'package:monefy_note_app/core/localization/locale_cubit.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Create cubits for testing
    final themeCubit = ThemeCubit();
    final localeCubit = LocalCubit();
    final colorCubit = ColorCubit();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      themeCubit: themeCubit,
      localeCubit: localeCubit,
      colorCubit: colorCubit,
    ));

    // Verify app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
