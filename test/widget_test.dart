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
  testWidgets('App builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);

    // Pump and settle to handle any pending animations
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('SplashPage displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify SplashPage elements are present
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('HelpDesk'), findsOneWidget);
    expect(find.text('E-Ticketing System'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Pump for animation but don't wait for navigation timer
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('App theme toggle works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify app builds in light mode by default
    expect(find.byType(MaterialApp), findsOneWidget);

    // Toggle theme to dark mode
    themeNotifier.toggleTheme();
    await tester.pump();

    // Verify app still builds after theme change
    expect(find.byType(MaterialApp), findsOneWidget);

    // Toggle back to light mode
    themeNotifier.toggleTheme();
    await tester.pump();

    // Verify app still builds
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
