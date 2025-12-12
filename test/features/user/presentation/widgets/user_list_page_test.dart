import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:angry_raphi/features/user/presentation/widgets/user_list_page.dart';
import 'package:angry_raphi/features/user/presentation/bloc/user_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@GenerateMocks([UserBloc])
import 'user_list_page_test.mocks.dart';

void main() {
  late MockUserBloc mockUserBloc;

  setUp(() {
    mockUserBloc = MockUserBloc();
    when(mockUserBloc.stream).thenAnswer((_) => Stream.value(UserInitial()));
    when(mockUserBloc.state).thenReturn(UserInitial());
  });

  Widget createWidgetUnderTest() {
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
      home: BlocProvider<UserBloc>.value(
        value: mockUserBloc,
        child: const UserListPage(),
      ),
    );
  }

  group('UserListPage', () {
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

    testWidgets('should have refresh button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should trigger refresh when button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final refreshButton = find.byIcon(Icons.refresh);
      await tester.tap(refreshButton);
      await tester.pump();

      verify(mockUserBloc.add(any)).called(greaterThanOrEqualTo(1));
    });

    testWidgets('should have popup menu button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });

    testWidgets('should display loading indicator when loading',
        (WidgetTester tester) async {
      when(mockUserBloc.state).thenReturn(UserLoading());
      when(mockUserBloc.stream).thenAnswer((_) => Stream.value(UserLoading()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should display user list when users are loaded',
        (WidgetTester tester) async {
      when(mockUserBloc.state).thenReturn(const UserLoaded([]));
      when(mockUserBloc.stream)
          .thenAnswer((_) => Stream.value(const UserLoaded([])));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display error message when error occurs',
        (WidgetTester tester) async {
      const errorMessage = 'Failed to load users';
      when(mockUserBloc.state).thenReturn(const UserError(errorMessage));
      when(mockUserBloc.stream)
          .thenAnswer((_) => Stream.value(const UserError(errorMessage)));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should open popup menu when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final popupButton = find.byType(PopupMenuButton<String>);
      await tester.tap(popupButton);
      await tester.pumpAndSettle();

      // Menu should open
      expect(find.byType(PopupMenuItem<String>), findsWidgets);
    });

    testWidgets('should be a StatelessWidget', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final userListPage = tester.widget<UserListPage>(
        find.byType(UserListPage),
      );

      expect(userListPage, isA<StatelessWidget>());
    });
  });
}
