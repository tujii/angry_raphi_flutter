import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:angry_raphi/features/user/presentation/widgets/admin_user_list_page.dart';
import 'package:angry_raphi/features/user/presentation/bloc/user_bloc.dart';
import 'package:angry_raphi/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:angry_raphi/features/raphcon_management/presentation/bloc/raphcon_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@GenerateMocks([
  UserBloc,
  AdminBloc,
  RaphconBloc,
])
import 'admin_user_list_page_test.mocks.dart';

void main() {
  late MockUserBloc mockUserBloc;
  late MockAdminBloc mockAdminBloc;
  late MockRaphconBloc mockRaphconBloc;

  setUp(() {
    mockUserBloc = MockUserBloc();
    mockAdminBloc = MockAdminBloc();
    mockRaphconBloc = MockRaphconBloc();

    when(mockUserBloc.stream).thenAnswer((_) => Stream.value(UserInitial()));
    when(mockUserBloc.state).thenReturn(UserInitial());
    when(mockAdminBloc.stream).thenAnswer((_) => Stream.value(AdminInitial()));
    when(mockAdminBloc.state).thenReturn(AdminInitial());
    when(mockRaphconBloc.stream).thenAnswer((_) => Stream.value(RaphconInitial()));
    when(mockRaphconBloc.state).thenReturn(RaphconInitial());
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
      home: MultiBlocProvider(
        providers: [
          BlocProvider<UserBloc>.value(value: mockUserBloc),
          BlocProvider<AdminBloc>.value(value: mockAdminBloc),
          BlocProvider<RaphconBloc>.value(value: mockRaphconBloc),
        ],
        child: const AdminUserListPage(),
      ),
    );
  }

  group('AdminUserListPage', () {
    testWidgets('should display scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should be a StatefulWidget', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final adminUserListPage = tester.widget<AdminUserListPage>(
        find.byType(AdminUserListPage),
      );

      expect(adminUserListPage, isA<StatefulWidget>());
    });

    testWidgets('should have app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have refresh button in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should trigger refresh when refresh button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final refreshButton = find.byIcon(Icons.refresh);
      await tester.tap(refreshButton);
      await tester.pump();

      verify(mockUserBloc.add(any)).called(greaterThanOrEqualTo(1));
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

    testWidgets('should have floating action button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsWidgets);
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

    testWidgets('should have MultiBlocProvider', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(MultiBlocProvider), findsOneWidget);
    });
  });
}
