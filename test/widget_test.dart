// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic MaterialApp smoke test', (WidgetTester tester) async {
    // Build a basic MaterialApp widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Test App')),
          body: const Center(
            child: Text('Test is working'),
          ),
        ),
      ),
    );

    // Pump one frame to render
    await tester.pump();

    // Verify basic widgets are present
    expect(find.text('Test App'), findsOneWidget);
    expect(find.text('Test is working'), findsOneWidget);
  });

  testWidgets('Widget creation works', (WidgetTester tester) async {
    // Simple test that verifies the test framework works
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Hello World'),
        ),
      ),
    );

    // Expect the text to be found
    expect(find.text('Hello World'), findsOneWidget);
  });
}
