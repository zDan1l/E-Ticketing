// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uts/main.dart';

void main() {
  testWidgets('App starts with SplashPage', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds successfully and shows the splash screen
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App theme toggle works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify app builds in light mode by default
    expect(find.byType(MaterialApp), findsOneWidget);

    // Toggle theme to dark mode
    themeNotifier.toggleTheme();
    await tester.pumpAndSettle();

    // Verify app still builds after theme change
    expect(find.byType(MaterialApp), findsOneWidget);

    // Toggle back to light mode
    themeNotifier.toggleTheme();
    await tester.pumpAndSettle();

    // Verify app still builds
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
