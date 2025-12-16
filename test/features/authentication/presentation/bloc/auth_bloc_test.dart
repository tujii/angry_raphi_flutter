import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/authentication/domain/entities/user_entity.dart';
import 'package:angry_raphi/features/authentication/domain/repositories/auth_repository.dart';
import 'package:angry_raphi/features/authentication/domain/usecases/get_current_user.dart';
import 'package:angry_raphi/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:angry_raphi/features/authentication/domain/usecases/sign_out.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_event.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([
  SignInWithGoogle,
  SignOut,
  GetCurrentUser,
  AuthRepository,
])
void main() {
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignOut mockSignOut;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignOut = MockSignOut();
    mockGetCurrentUser = MockGetCurrentUser();
    mockAuthRepository = MockAuthRepository();

    // Default stub for auth state changes stream
    when(mockAuthRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
  });

  final tUserEntity = UserEntity(
    id: 'test-uid',
    email: 'test@example.com',
    displayName: 'Test User',
    isAdmin: false,
    createdAt: DateTime(2024),
  );

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      // arrange & act
      final bloc = AuthBloc(
        mockSignInWithGoogle,
        mockSignOut,
        mockGetCurrentUser,
        mockAuthRepository,
      );

      // assert
      expect(bloc.state, AuthInitial());

      // cleanup
      bloc.close();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when AuthStarted is added and user is signed in',
      build: () {
        when(mockGetCurrentUser()).thenAnswer((_) async => Right(tUserEntity));
        return AuthBloc(
          mockSignInWithGoogle,
          mockSignOut,
          mockGetCurrentUser,
          mockAuthRepository,
        );
      },
      act: (bloc) => bloc.add(AuthStarted()),
      expect: () => [
        AuthLoading(),
        AuthAuthenticated(tUserEntity),
      ],
      verify: (_) {
        verify(mockGetCurrentUser()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when AuthStarted is added and no user is signed in',
      build: () {
        when(mockGetCurrentUser()).thenAnswer((_) async => const Right(null));
        return AuthBloc(
          mockSignInWithGoogle,
          mockSignOut,
          mockGetCurrentUser,
          mockAuthRepository,
        );
      },
      act: (bloc) => bloc.add(AuthStarted()),
      expect: () => [
        AuthLoading(),
        AuthUnauthenticated(),
      ],
      verify: (_) {
        verify(mockGetCurrentUser()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when AuthStarted is added and getCurrentUser fails',
      build: () {
        when(mockGetCurrentUser()).thenAnswer(
            (_) async => const Left(AuthFailure('Failed to get user')));
        return AuthBloc(
          mockSignInWithGoogle,
          mockSignOut,
          mockGetCurrentUser,
          mockAuthRepository,
        );
      },
      act: (bloc) => bloc.add(AuthStarted()),
      expect: () => [
        AuthLoading(),
        AuthUnauthenticated(),
      ],
      verify: (_) {
        verify(mockGetCurrentUser()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when AuthSignInRequested is successful',
      build: () {
        when(mockSignInWithGoogle())
            .thenAnswer((_) async => Right(tUserEntity));
        return AuthBloc(
          mockSignInWithGoogle,
          mockSignOut,
          mockGetCurrentUser,
          mockAuthRepository,
        );
      },
      act: (bloc) => bloc.add(AuthSignInRequested()),
      expect: () => [
        AuthLoading(),
        AuthAuthenticated(tUserEntity),
      ],
      verify: (_) {
        verify(mockSignInWithGoogle()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when AuthSignInRequested fails',
      build: () {
        when(mockSignInWithGoogle())
            .thenAnswer((_) async => const Left(AuthFailure('Sign in failed')));
        return AuthBloc(
          mockSignInWithGoogle,
          mockSignOut,
          mockGetCurrentUser,
          mockAuthRepository,
        );
      },
      act: (bloc) => bloc.add(AuthSignInRequested()),
      expect: () => [
        AuthLoading(),
        AuthError('Sign in failed'),
      ],
      verify: (_) {
        verify(mockSignInWithGoogle()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when AuthSignOutRequested is successful',
      build: () {
        when(mockSignOut()).thenAnswer((_) async => const Right(null));
        return AuthBloc(
          mockSignInWithGoogle,
          mockSignOut,
          mockGetCurrentUser,
          mockAuthRepository,
        );
      },
      act: (bloc) => bloc.add(AuthSignOutRequested()),
      expect: () => [
        AuthLoading(),
        AuthUnauthenticated(),
      ],
      verify: (_) {
        verify(mockSignOut()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when AuthSignOutRequested fails',
      build: () {
        when(mockSignOut()).thenAnswer(
            (_) async => const Left(AuthFailure('Sign out failed')));
        return AuthBloc(
          mockSignInWithGoogle,
          mockSignOut,
          mockGetCurrentUser,
          mockAuthRepository,
        );
      },
      act: (bloc) => bloc.add(AuthSignOutRequested()),
      expect: () => [
        AuthLoading(),
        AuthError('Sign out failed'),
      ],
      verify: (_) {
        verify(mockSignOut()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthAuthenticated] when AuthUserChanged is added with a user',
      build: () => AuthBloc(
        mockSignInWithGoogle,
        mockSignOut,
        mockGetCurrentUser,
        mockAuthRepository,
      ),
      act: (bloc) => bloc.add(AuthUserChanged(tUserEntity)),
      expect: () => [
        AuthAuthenticated(tUserEntity),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when AuthUserChanged is added with null user',
      build: () => AuthBloc(
        mockSignInWithGoogle,
        mockSignOut,
        mockGetCurrentUser,
        mockAuthRepository,
      ),
      act: (bloc) => bloc.add(AuthUserChanged(null)),
      expect: () => [
        AuthUnauthenticated(),
      ],
    );

    test('listens to authStateChanges and adds AuthUserChanged events',
        () async {
      // arrange
      final userStream = Stream.value(tUserEntity);
      when(mockAuthRepository.authStateChanges).thenAnswer((_) => userStream);

      // act
      final bloc = AuthBloc(
        mockSignInWithGoogle,
        mockSignOut,
        mockGetCurrentUser,
        mockAuthRepository,
      );

      // wait for stream to emit
      await Future.delayed(const Duration(milliseconds: 100));

      // assert
      verify(mockAuthRepository.authStateChanges).called(1);

      // cleanup
      await bloc.close();
    });

    test('cancels auth state subscription on close', () async {
      // arrange
      final bloc = AuthBloc(
        mockSignInWithGoogle,
        mockSignOut,
        mockGetCurrentUser,
        mockAuthRepository,
      );

      // act
      await bloc.close();

      // assert - no exception should be thrown
      expect(bloc.isClosed, true);
    });
  });
}
