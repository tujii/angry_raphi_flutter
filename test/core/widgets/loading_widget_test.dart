import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/core/widgets/loading_widget.dart';
import 'package:angry_raphi/core/constants/app_constants.dart';

void main() {
  group('LoadingWidget', () {
    testWidgets('should display CircularProgressIndicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display message when provided', (WidgetTester tester) async {
      const testMessage = 'Loading...';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(message: testMessage),
          ),
        ),
      );

      expect(find.text(testMessage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should not display message when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should use custom size when provided', (WidgetTester tester) async {
      const customSize = 100.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(size: customSize),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.width, customSize);
      expect(sizedBox.height, customSize);
    });

    testWidgets('should use default size when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.width, 50.0);
      expect(sizedBox.height, 50.0);
    });

    testWidgets('should be centered', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    });
  });
}
