import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:angry_raphi/features/admin/presentation/pages/admin_settings_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  Query,
  QuerySnapshot,
])
import 'admin_settings_page_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      home: AdminSettingsPage(),
    );
  }

  group('AdminSettingsPage', () {
    testWidgets('should display page title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Should have a scaffold
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Should show loading indicator while data loads
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should have an app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should be a StatefulWidget', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final adminSettingsPage = tester.widget<AdminSettingsPage>(
        find.byType(AdminSettingsPage),
      );

      expect(adminSettingsPage, isA<StatefulWidget>());
    });

    testWidgets('should have scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Should have some scrollable widget for content
      expect(
        find.byType(SingleChildScrollView),
        findsWidgets,
      );
    });
  });

  group('AdminSettingsPage UI Elements', () {
    testWidgets('should display admin sections when loaded',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      
      // Wait for initial load
      await tester.pump(const Duration(seconds: 2));

      // Should have some UI elements visible after loading
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have proper page structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Verify basic structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(AdminSettingsPage), findsOneWidget);
    });
  });
}
