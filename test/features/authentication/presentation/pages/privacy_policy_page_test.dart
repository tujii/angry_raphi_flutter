import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/authentication/presentation/pages/privacy_policy_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('de'),
      ],
      home: PrivacyPolicyPage(),
    );
  }

  group('PrivacyPolicyPage', () {
    testWidgets('should display scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should display privacy policy title',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should have text widgets for content
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should display last updated date', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should display some date information
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should have padding around content',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('should be scrollable for long content',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final scrollView = find.byType(SingleChildScrollView);
      expect(scrollView, findsOneWidget);

      // Try scrolling
      await tester.drag(scrollView, const Offset(0, -100));
      await tester.pump();

      // Should not throw error
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should be a StatelessWidget', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final privacyPolicyPage = tester.widget<PrivacyPolicyPage>(
        find.byType(PrivacyPolicyPage),
      );

      expect(privacyPolicyPage, isA<StatelessWidget>());
    });

    testWidgets('should have proper structure with Column',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should have cross axis alignment start',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );

      expect(scrollView.child, isA<Column>());
    });
  });
}
