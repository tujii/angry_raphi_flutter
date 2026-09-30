import 'dart:async';

import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/authentication/domain/entities/user_entity.dart';
import 'package:angry_raphi/features/authentication/domain/repositories/auth_repository.dart';
import 'package:angry_raphi/features/authentication/domain/usecases/get_current_user.dart';
import 'package:angry_raphi/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:angry_raphi/features/authentication/domain/usecases/sign_out.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_event.dart';
import 'package:angry_raphi/features/spaces/domain/repositories/spaces_repository.dart';
import 'package:angry_raphi/features/spaces/presentation/pages/create_space_page.dart';
import 'package:angry_raphi/features/spaces/presentation/pages/join_space_page.dart';
import 'package:angry_raphi/features/spaces/presentation/pages/space_home_page.dart';
import 'package:angry_raphi/features/spaces/presentation/pages/spaces_page.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'stream_spaces_repository.dart';

class FakeAuthRepository implements AuthRepository {
  final changes = StreamController<UserEntity?>();

  @override
  Stream<UserEntity?> get authStateChanges => changes.stream;

  void dispose() => unawaited(changes.close());

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async =>
      const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

final testUser = UserEntity(
  id: 'uid1',
  email: 'max@example.com',
  displayName: 'Max',
  isAdmin: false,
  createdAt: DateTime(2024),
);

void main() {
  late StreamSpacesRepository spacesRepository;
  late FakeAuthRepository authRepository;
  late AuthBloc authBloc;

  // Created inside each test body (not setUp) so that bloc and stream
  // events run in the widget test's fake-async zone.
  Future<void> pumpApp(WidgetTester tester, String initialLocation) async {
    spacesRepository = StreamSpacesRepository();
    authRepository = FakeAuthRepository();
    authBloc = AuthBloc(
      SignInWithGoogle(authRepository),
      SignOut(authRepository),
      GetCurrentUser(authRepository),
      authRepository,
    );
    addTearDown(() async {
      await authBloc.close();
      authRepository.dispose();
      spacesRepository.dispose();
    });

    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/spaces',
          builder: (_, __) => const SpacesPage(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (_, __) => const CreateSpacePage(),
            ),
          ],
        ),
        GoRoute(
          path: '/s/:spaceId',
          builder: (_, state) =>
              SpaceHomePage(spaceId: state.pathParameters['spaceId']!),
        ),
        GoRoute(
          path: '/join/:spaceId/:code',
          builder: (_, state) => JoinSpacePage(
            spaceId: state.pathParameters['spaceId']!,
            code: state.pathParameters['code']!,
          ),
        ),
        GoRoute(path: '/', builder: (_, __) => const Text('home')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      RepositoryProvider<SpacesRepository>.value(
        value: spacesRepository,
        child: BlocProvider.value(
          value: authBloc,
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('de'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      ),
    );
    authBloc.add(AuthUserChanged(testUser));
    // Not pumpAndSettle: pages show progress indicators until the test
    // feeds their streams.
    await tester.pump();
    await tester.pump();
  }

  group('SpacesPage', () {
    testWidgets('shows an empty state', (tester) async {
      await pumpApp(tester, '/spaces');
      spacesRepository.mySpaces.add(const Right([]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Meine Bereiche'), findsOneWidget);
      expect(find.text('Du bist noch in keinem Bereich.'), findsOneWidget);
      expect(find.text('Bereich anlegen'), findsOneWidget);
    });

    testWidgets('lists spaces and opens one', (tester) async {
      await pumpApp(tester, '/spaces');
      spacesRepository.mySpaces.add(Right([testSpace]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Team Rocket'), findsOneWidget);
      expect(find.text('Prepare for trouble'), findsOneWidget);

      await tester.tap(find.text('Team Rocket'));
      // The space page waits for the membership stream
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(SpaceHomePage), findsOneWidget);
    });

    testWidgets('asks to sign in when signed out', (tester) async {
      await pumpApp(tester, '/spaces');
      authBloc.add(AuthUserChanged(null));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Anmelden'), findsOneWidget);
    });
  });

  group('CreateSpacePage', () {
    testWidgets('validates the name', (tester) async {
      await pumpApp(tester, '/spaces/new');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Bereich anlegen'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Bitte gib einen Namen ein'), findsOneWidget);
      expect(spacesRepository.lastCreate, isNull);
    });

    testWidgets('creates the space and opens it', (tester) async {
      await pumpApp(tester, '/spaces/new');

      await tester.enterText(find.byType(TextFormField).first, ' Team ');
      await tester.enterText(find.byType(TextFormField).last, 'Our team');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Bereich anlegen'));
      await tester.pump();
      await tester.pump();

      final params = spacesRepository.lastCreate!;
      expect(params.name, 'Team');
      expect(params.description, 'Our team');
      expect(params.ownerUid, 'uid1');
      expect(params.ownerEmail, 'max@example.com');
      expect(find.byType(SpaceHomePage), findsOneWidget);
    });
  });

  group('SpaceHomePage', () {
    testWidgets('shows no access for non-members', (tester) async {
      await pumpApp(tester, '/s/space1');
      spacesRepository.membership.add(const Right(null));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text('Diesen Bereich gibt es nicht oder du hast keinen Zugriff.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Zurück zu meinen Bereichen'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(SpacesPage), findsOneWidget);
    });
  });
  group('JoinSpacePage', () {
    testWidgets('joins with a valid link', (tester) async {
      await pumpApp(tester, '/join/space1/abcdefghijklmnopqrstuvwx');
      spacesRepository.inviteCode = Right(testInvite());
      spacesRepository.membership.add(const Right(null));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text('Du wurdest in „Team Rocket“ als Mitglied eingeladen.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Beitreten'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(spacesRepository.joinedWith, testInvite());
      expect(spacesRepository.joinedAs!.uid, 'uid1');
      expect(find.byType(SpaceHomePage), findsOneWidget);
    });

    testWidgets('explains invalid links', (tester) async {
      await pumpApp(tester, '/join/space1/unknown');
      spacesRepository.membership.add(const Right(null));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text('Dieser Einladungslink ist ungültig oder abgelaufen.'),
        findsOneWidget,
      );
    });
  });

  group('SpacesPage invitations', () {
    testWidgets('accepting an invitation opens the space', (tester) async {
      await pumpApp(tester, '/spaces');
      spacesRepository.mySpaces.add(const Right([]));
      spacesRepository.myInvitations.add(Right([testInvitation]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Deine Einladungen'), findsOneWidget);
      expect(find.text('Eingeladen als Mitglied'), findsOneWidget);

      await tester.tap(find.text('Annehmen'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(spacesRepository.accepted, testInvitation);
      expect(find.byType(SpaceHomePage), findsOneWidget);
    });
  });
}
