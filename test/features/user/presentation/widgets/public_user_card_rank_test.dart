import 'package:angry_raphi/features/user/domain/entities/user.dart';
import 'package:angry_raphi/features/user/presentation/widgets/public_user_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PublicUserCard Rank Display', () {
    late User testUser;

    setUp(() {
      testUser = User(
        id: 'test-user-1',
        initials: 'TU',
        raphconCount: 10,
        createdAt: DateTime.now(),
      );
    });

    Widget createTestWidget(int? rank) {
      return MaterialApp(
        home: Scaffold(
          body: PublicUserCard(
            user: testUser,
            isAdmin: false,
            isLoggedIn: false,
            rank: rank,
          ),
        ),
      );
    }

    testWidgets('displays rank badge for rank 1 (gold)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(1));

      // Should show trophy icon for rank 1
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      
      // Should display "1." text
      expect(find.text('1.'), findsOneWidget);
    });

    testWidgets('displays rank badge for rank 2 (silver)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(2));

      // Should show trophy icon for rank 2
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      
      // Should display "2." text
      expect(find.text('2.'), findsOneWidget);
    });

    testWidgets('displays rank badge for rank 3 (bronze)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(3));

      // Should show trophy icon for rank 3
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      
      // Should display "3." text
      expect(find.text('3.'), findsOneWidget);
    });

    testWidgets('does not display rank badge for rank 4', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(4));

      // Should NOT show trophy icon for rank 4
      expect(find.byIcon(Icons.emoji_events), findsNothing);
      
      // Should NOT display "4." text
      expect(find.text('4.'), findsNothing);
    });

    testWidgets('does not display rank badge when rank is null', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(null));

      // Should NOT show trophy icon when rank is null
      expect(find.byIcon(Icons.emoji_events), findsNothing);
    });

    testWidgets('does not display rank badge for rank 0 (edge case)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(0));

      // Should NOT show trophy icon for rank 0
      expect(find.byIcon(Icons.emoji_events), findsNothing);
      
      // Should NOT display "0." text
      expect(find.text('0.'), findsNothing);
    });

    testWidgets('does not display rank badge for negative rank (edge case)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(-1));

      // Should NOT show trophy icon for negative rank
      expect(find.byIcon(Icons.emoji_events), findsNothing);
    });

    testWidgets('displays user name regardless of rank', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(1));

      // Should always display user initials
      expect(find.text('TU'), findsOneWidget);
    });
  });
}
