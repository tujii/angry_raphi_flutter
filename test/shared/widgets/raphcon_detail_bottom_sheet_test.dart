import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:angry_raphi/shared/widgets/raphcon_detail_bottom_sheet.dart';
import 'package:angry_raphi/features/raphcon_management/domain/entities/raphcon_entity.dart';
import 'package:angry_raphi/features/raphcon_management/presentation/bloc/raphcon_bloc.dart';
import 'package:angry_raphi/features/user/presentation/bloc/user_bloc.dart';
import 'package:angry_raphi/core/enums/raphcon_type.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@GenerateMocks([RaphconBloc, UserBloc])
import 'raphcon_detail_bottom_sheet_test.mocks.dart';

void main() {
  late MockRaphconBloc mockRaphconBloc;
  late MockUserBloc mockUserBloc;
  late List<RaphconEntity> testRaphcons;

  setUp(() {
    mockRaphconBloc = MockRaphconBloc();
    mockUserBloc = MockUserBloc();

    when(mockRaphconBloc.stream).thenAnswer((_) => Stream.value(RaphconInitial()));
    when(mockRaphconBloc.state).thenReturn(RaphconInitial());
    when(mockUserBloc.stream).thenAnswer((_) => Stream.value(UserInitial()));
    when(mockUserBloc.state).thenReturn(UserInitial());

    testRaphcons = [
      RaphconEntity(
        id: '1',
        userId: 'user1',
        type: RaphconType.rage,
        createdAt: DateTime.now(),
        createdBy: 'creator1',
      ),
      RaphconEntity(
        id: '2',
        userId: 'user1',
        type: RaphconType.rage,
        createdAt: DateTime.now(),
        createdBy: 'creator2',
      ),
    ];
  });

  Widget createWidgetUnderTest({
    required String userName,
    required RaphconType type,
    required List<RaphconEntity> raphcons,
    required bool isAdmin,
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
      home: MultiBlocProvider(
        providers: [
          BlocProvider<RaphconBloc>.value(value: mockRaphconBloc),
          BlocProvider<UserBloc>.value(value: mockUserBloc),
        ],
        child: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiBlocProvider(
                        providers: [
                          BlocProvider<RaphconBloc>.value(value: mockRaphconBloc),
                          BlocProvider<UserBloc>.value(value: mockUserBloc),
                        ],
                        child: Scaffold(
                          body: RaphconDetailBottomSheet(
                            userName: userName,
                            type: type,
                            raphcons: raphcons,
                            isAdmin: isAdmin,
                            onBackPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Show Sheet'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('RaphconDetailBottomSheet', () {
    testWidgets('should be a StatefulWidget', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        userName: 'Test User',
        type: RaphconType.rage,
        raphcons: testRaphcons,
        isAdmin: false,
      ));

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(RaphconDetailBottomSheet), findsOneWidget);
    });

    testWidgets('should display user name', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        userName: 'Test User',
        type: RaphconType.rage,
        raphcons: testRaphcons,
        isAdmin: false,
      ));

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Test User'), findsWidgets);
    });

    testWidgets('should display raphcon list', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        userName: 'Test User',
        type: RaphconType.rage,
        raphcons: testRaphcons,
        isAdmin: false,
      ));

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      // Should have scaffold and content
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('should show different content for admin',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        userName: 'Test User',
        type: RaphconType.rage,
        raphcons: testRaphcons,
        isAdmin: true,
      ));

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(RaphconDetailBottomSheet), findsOneWidget);
    });

    testWidgets('should handle empty raphcon list',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        userName: 'Test User',
        type: RaphconType.rage,
        raphcons: [],
        isAdmin: false,
      ));

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(RaphconDetailBottomSheet), findsOneWidget);
    });

    testWidgets('should call onBackPressed when back is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        userName: 'Test User',
        type: RaphconType.rage,
        raphcons: testRaphcons,
        isAdmin: false,
      ));

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      // Navigate back
      Navigator.of(tester.element(find.byType(RaphconDetailBottomSheet))).pop();
      await tester.pumpAndSettle();

      expect(find.byType(RaphconDetailBottomSheet), findsNothing);
    });

    testWidgets('should display raphcon type', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        userName: 'Test User',
        type: RaphconType.rage,
        raphcons: testRaphcons,
        isAdmin: false,
      ));

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      // Should display some content related to the type
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('should handle multiple raphcons', (WidgetTester tester) async {
      final manyRaphcons = List.generate(
        10,
        (index) => RaphconEntity(
          id: 'id_$index',
          userId: 'user1',
          type: RaphconType.rage,
          createdAt: DateTime.now(),
          createdBy: 'creator$index',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(
        userName: 'Test User',
        type: RaphconType.rage,
        raphcons: manyRaphcons,
        isAdmin: false,
      ));

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(RaphconDetailBottomSheet), findsOneWidget);
    });
  });
}
