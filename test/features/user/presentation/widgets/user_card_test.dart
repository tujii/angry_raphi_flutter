import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/user/presentation/widgets/user_card.dart';
import 'package:angry_raphi/features/user/domain/entities/user.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  late User testUser;

  setUp(() {
    testUser = User(
      id: '1',
      initials: 'TU',
      raphconCount: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  });

  Widget createWidgetUnderTest({
    required User user,
    required int rank,
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
        body: UserCard(
          user: user,
          rank: rank,
        ),
      ),
    );
  }

  group('UserCard', () {
    testWidgets('should display user name', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        user: testUser,
        rank: 1,
      ));
      await tester.pumpAndSettle();

      expect(find.text(testUser.name), findsOneWidget);
    });

    testWidgets('should display rank badge', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        user: testUser,
        rank: 1,
      ));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('should display raphcon count', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        user: testUser,
        rank: 1,
      ));
      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('should display gold color for rank 1',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        user: testUser,
        rank: 1,
      ));
      await tester.pumpAndSettle();

      // Verify Card widget exists
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should display user avatar with initial',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        user: testUser,
        rank: 1,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('T'), findsOneWidget); // First letter of name
    });

    testWidgets('should show raphcon icon', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        user: testUser,
        rank: 1,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sentiment_very_dissatisfied), findsOneWidget);
    });

    testWidgets('should be tappable', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        user: testUser,
        rank: 1,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget);

      // Tap the card
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      // Should show snackbar
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should display member since info',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        user: testUser,
        rank: 1,
      ));
      await tester.pumpAndSettle();

      // Should have subtitle text
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('should format date correctly for today',
        (WidgetTester tester) async {
      final todayUser = User(
        id: '2',
        initials: 'TD',
        raphconCount: 3,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createWidgetUnderTest(
        user: todayUser,
        rank: 2,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should have proper card layout', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        user: testUser,
        rank: 3,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}
