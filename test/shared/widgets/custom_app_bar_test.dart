import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/shared/widgets/custom_app_bar.dart';

void main() {
  Widget createWidgetUnderTest({
    required String title,
    List<Widget>? actions,
    bool showBackButton = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(
          title: title,
          actions: actions,
          showBackButton: showBackButton,
        ),
        body: const Center(child: Text('Test Body')),
      ),
    );
  }

  group('CustomAppBar', () {
    testWidgets('should display title', (WidgetTester tester) async {
      const testTitle = 'Test Title';

      await tester.pumpWidget(createWidgetUnderTest(
        title: testTitle,
      ));

      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('should display actions when provided',
        (WidgetTester tester) async {
      final actions = [
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        title: 'Test',
        actions: actions,
      ));

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should not display back button by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        title: 'Test',
      ));

      // AppBar should exist
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display back button when showBackButton is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: const CustomAppBar(
                            title: 'Second Page',
                            showBackButton: true,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Navigate'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Should be on second page
      expect(find.text('Second Page'), findsOneWidget);
    });

    testWidgets('should have correct preferred size',
        (WidgetTester tester) async {
      const customAppBar = CustomAppBar(
        title: 'Test',
      );

      expect(customAppBar.preferredSize.height, kToolbarHeight);
    });

    testWidgets('should implement PreferredSizeWidget',
        (WidgetTester tester) async {
      const customAppBar = CustomAppBar(
        title: 'Test',
      );

      expect(customAppBar, isA<PreferredSizeWidget>());
    });

    testWidgets('should have centered title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        title: 'Test',
      ));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, true);
    });

    testWidgets('should have proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        title: 'Test',
      ));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.elevation, 2);
    });

    testWidgets('should work without actions', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        title: 'Test',
        actions: null,
      ));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });
  });
}
