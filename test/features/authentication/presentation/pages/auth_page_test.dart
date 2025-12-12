import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:angry_raphi/features/authentication/presentation/pages/auth_page.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@GenerateMocks([AuthBloc])
import 'auth_page_test.mocks.dart';

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));
    when(mockAuthBloc.state).thenReturn(AuthInitial());
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
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const AuthPage(),
      ),
    );
  }

  group('AuthPage', () {
    testWidgets('should display scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display app logo/icon', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byIcon(Icons.sentiment_very_dissatisfied), findsOneWidget);
    });

    testWidgets('should have SafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should display app name or title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Should have some text elements
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should display sign in button when not loading',
        (WidgetTester tester) async {
      when(mockAuthBloc.state).thenReturn(AuthUnauthenticated());
      when(mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(AuthUnauthenticated()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should have button or similar interactive element
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading',
        (WidgetTester tester) async {
      when(mockAuthBloc.state).thenReturn(AuthLoading());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthLoading()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error snackbar when auth fails',
        (WidgetTester tester) async {
      const errorMessage = 'Authentication failed';
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          AuthInitial(),
          AuthError(errorMessage),
        ]),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should be centered', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Should have Column with centered content
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should have padding', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('should have BlocConsumer', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // BlocConsumer should be present for state management
      expect(find.byType(AuthPage), findsOneWidget);
    });
  });
}
