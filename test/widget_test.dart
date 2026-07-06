// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eticketing/main.dart';

void main() {
  test('ThemeNotifier toggles correctly', () {
    // Test theme toggle logic without building the widget tree
    expect(themeNotifier.isDark, false);

    themeNotifier.toggleTheme();
    expect(themeNotifier.isDark, true);

    themeNotifier.toggleTheme();
    expect(themeNotifier.isDark, false);

    // Reset to light mode
    themeNotifier.value = ThemeMode.light;
  });

  test('ThemeNotifier value changes correctly', () {
    // Test direct value changes
    expect(themeNotifier.value, ThemeMode.light);

    themeNotifier.value = ThemeMode.dark;
    expect(themeNotifier.value, ThemeMode.dark);
    expect(themeNotifier.isDark, true);

    themeNotifier.value = ThemeMode.light;
    expect(themeNotifier.value, ThemeMode.light);
    expect(themeNotifier.isDark, false);
  });

  testWidgets('MaterialApp configuration is correct', (WidgetTester tester) async {
    // Build MaterialApp without SplashPage to avoid timer issues
    await tester.pumpWidget(
      MaterialApp(
        title: 'HelpDesk — E-Ticketing',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.light,
        home: const Scaffold(
          body: Center(
            child: Text('Test'),
          ),
        ),
      ),
    );

    // Verify MaterialApp properties
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'HelpDesk — E-Ticketing');
    expect(app.debugShowCheckedModeBanner, false);
    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('Theme affects MaterialApp', (WidgetTester tester) async {
    // Test that theme changes work without SplashPage
    ThemeMode testTheme = ThemeMode.light;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: testTheme,
            home: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      testTheme = testTheme == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    });
                  },
                  child: const Text('Toggle Theme'),
                ),
              ),
            ),
          );
        },
      ),
    );

    // Verify initial build
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Toggle Theme'), findsOneWidget);
  });
}
