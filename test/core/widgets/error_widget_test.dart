import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/core/widgets/error_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  group('ErrorDisplayWidget', () {
    Widget createWidgetUnderTest({
      required String message,
      VoidCallback? onRetry,
      IconData? icon,
    }) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('de'),
        ],
        home: Scaffold(
          body: ErrorDisplayWidget(
            message: message,
            onRetry: onRetry,
            icon: icon,
          ),
        ),
      );
    }

    testWidgets('should display error message', (WidgetTester tester) async {
      const errorMessage = 'Something went wrong';
      
      await tester.pumpWidget(
        createWidgetUnderTest(message: errorMessage),
      );

      expect(find.text(errorMessage), findsOneWidget);
      // Verify error title is displayed (checking for any text widget with headline style)
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should display default error icon when icon is not provided', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(message: 'Error'),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display custom icon when provided', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          message: 'Error',
          icon: Icons.warning,
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('should display retry button when onRetry is provided', 
        (WidgetTester tester) async {
      bool retryPressed = false;
      
      await tester.pumpWidget(
        createWidgetUnderTest(
          message: 'Error',
          onRetry: () => retryPressed = true,
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      expect(retryPressed, true);
    });

    testWidgets('should not display retry button when onRetry is null', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(message: 'Error'),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('should be centered', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(message: 'Error'),
      );

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should have padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(message: 'Error'),
      );

      expect(find.byType(Padding), findsWidgets);
    });
  });
}
