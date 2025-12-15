import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/authentication/presentation/widgets/google_sign_in_button.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest({
    required VoidCallback onPressed,
    bool isLoading = false,
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
        body: GoogleSignInButton(
          onPressed: onPressed,
          isLoading: isLoading,
        ),
      ),
    );
  }

  group('GoogleSignInButton', () {
    testWidgets('should display sign in text when not loading',
        (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(createWidgetUnderTest(
        onPressed: () => wasPressed = true,
        isLoading: false,
      ));
      await tester.pumpAndSettle();

      // Should find text elements
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should display loading indicator when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onPressed: () {},
        isLoading: true,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped and not loading',
        (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(createWidgetUnderTest(
        onPressed: () => wasPressed = true,
        isLoading: false,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GoogleSignInButton));
      await tester.pump();

      expect(wasPressed, true);
    });

    testWidgets('should not call onPressed when loading',
        (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(createWidgetUnderTest(
        onPressed: () => wasPressed = true,
        isLoading: true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GoogleSignInButton));
      await tester.pump();

      expect(wasPressed, false);
    });

    testWidgets('should have proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onPressed: () {},
        isLoading: false,
      ));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GoogleSignInButton),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('should display image or fallback',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onPressed: () {},
        isLoading: false,
      ));
      await tester.pumpAndSettle();

      // Should have either image or fallback text
      expect(
        find.byType(Image).evaluate().isNotEmpty ||
            find.text('G').evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('should have InkWell for touch feedback',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onPressed: () {},
        isLoading: false,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('should have proper layout with Row',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onPressed: () {},
        isLoading: false,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Row), findsOneWidget);
    });
  });
}
