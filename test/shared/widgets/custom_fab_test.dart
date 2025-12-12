import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/shared/widgets/custom_fab.dart';

void main() {
  group('CustomFAB', () {
    testWidgets('should display FloatingActionButton with icon', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomFAB(
              onPressed: () {},
              icon: Icons.add,
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', 
        (WidgetTester tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomFAB(
              onPressed: () => pressed = true,
              icon: Icons.add,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      expect(pressed, true);
    });

    testWidgets('should display tooltip when provided', 
        (WidgetTester tester) async {
      const testTooltip = 'Add Item';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomFAB(
              onPressed: () {},
              icon: Icons.add,
              tooltip: testTooltip,
            ),
          ),
        ),
      );

      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );

      expect(fab.tooltip, testTooltip);
    });

    testWidgets('should not have tooltip when not provided', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomFAB(
              onPressed: () {},
              icon: Icons.add,
            ),
          ),
        ),
      );

      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );

      expect(fab.tooltip, isNull);
    });

    testWidgets('should display different icons', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomFAB(
              onPressed: () {},
              icon: Icons.edit,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
    });
  });
}
