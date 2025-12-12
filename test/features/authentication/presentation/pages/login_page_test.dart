import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:angry_raphi/features/authentication/presentation/pages/login_page.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_state.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_event.dart';
import 'package:angry_raphi/features/authentication/domain/entities/user_entity.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@GenerateMocks([AuthBloc])
import 'login_page_test.mocks.dart';

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));
    when(mockAuthBloc.state).thenReturn(AuthInitial());
  });

  Widget createWidgetUnderTest({bool isDialog = false}) {
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
        child: LoginPage(isDialog: isDialog),
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('should display logo and welcome text', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Logo should be displayed
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should display Google sign in button when not loading',
        (WidgetTester tester) async {
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Google sign in button should be displayed
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should display loading indicator when loading',
        (WidgetTester tester) async {
      when(mockAuthBloc.state).thenReturn(AuthLoading());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthLoading()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should trigger sign in when button is tapped',
        (WidgetTester tester) async {
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find and tap the sign in button
      final signInButton = find.byType(ElevatedButton).first;
      await tester.tap(signInButton);
      await tester.pump();

      verify(mockAuthBloc.add(any)).called(greaterThanOrEqualTo(1));
    });

    testWidgets('should show error message when authentication fails',
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

      // SnackBar with error should be shown
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should show success message when authentication succeeds',
        (WidgetTester tester) async {
      final testUser = UserEntity(
        id: '1',
        email: 'test@example.com',
        displayName: 'Test User',
        isAdmin: false,
        createdAt: DateTime.now(),
      );

      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          AuthInitial(),
          AuthAuthenticated(testUser),
        ]),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // SnackBar with success message should be shown
      expect(find.textContaining('Test User'), findsOneWidget);
    });

    testWidgets('should display app bar when isDialog is true',
        (WidgetTester tester) async {
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

      await tester.pumpWidget(createWidgetUnderTest(isDialog: true));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should not display app bar when isDialog is false',
        (WidgetTester tester) async {
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

      await tester.pumpWidget(createWidgetUnderTest(isDialog: false));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('should have terms and privacy policy links',
        (WidgetTester tester) async {
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should find text buttons for terms and privacy
      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('should have SafeArea', (WidgetTester tester) async {
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
