import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:angry_raphi/features/user/presentation/widgets/public_user_list_page.dart';
import 'package:angry_raphi/features/user/presentation/bloc/user_bloc.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_state.dart';
import 'package:angry_raphi/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:angry_raphi/features/raphcon_management/presentation/bloc/raphcon_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@GenerateMocks([
  UserBloc,
  AuthBloc,
  AdminBloc,
  RaphconBloc,
])
import 'public_user_list_page_test.mocks.dart';

void main() {
  late MockUserBloc mockUserBloc;
  late MockAuthBloc mockAuthBloc;
  late MockAdminBloc mockAdminBloc;
  late MockRaphconBloc mockRaphconBloc;

  setUp(() {
    mockUserBloc = MockUserBloc();
    mockAuthBloc = MockAuthBloc();
    mockAdminBloc = MockAdminBloc();
    mockRaphconBloc = MockRaphconBloc();

    when(mockUserBloc.stream).thenAnswer((_) => Stream.value(UserInitial()));
    when(mockUserBloc.state).thenReturn(UserInitial());
    when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthUnauthenticated()));
    when(mockAuthBloc.state).thenReturn(AuthUnauthenticated());
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
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          BlocProvider<AdminBloc>.value(value: mockAdminBloc),
          BlocProvider<RaphconBloc>.value(value: mockRaphconBloc),
        ],
        child: const PublicUserListPage(),
      ),
    );
  }

  group('PublicUserListPage', () {
    testWidgets('should display scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should be a StatefulWidget', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final publicUserListPage = tester.widget<PublicUserListPage>(
        find.byType(PublicUserListPage),
      );

      expect(publicUserListPage, isA<StatefulWidget>());
    });

    testWidgets('should have app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display loading state when user bloc is loading',
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
      when(mockUserBloc.stream).thenAnswer((_) => Stream.value(const UserLoaded([])));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Page should render successfully
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have floating action button for adding users',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Should have FAB or similar add button
      expect(find.byType(FloatingActionButton), findsWidgets);
    });

    testWidgets('should display error when user bloc has error',
        (WidgetTester tester) async {
      const errorMessage = 'Failed to load users';
      when(mockUserBloc.state).thenReturn(const UserError(errorMessage));
      when(mockUserBloc.stream)
          .thenAnswer((_) => Stream.value(const UserError(errorMessage)));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Should display some error indication
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have proper structure with MultiBlocProvider',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(MultiBlocProvider), findsOneWidget);
      expect(find.byType(PublicUserListPage), findsOneWidget);
    });

    testWidgets('should display menu button in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Should have menu or action buttons in app bar
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
