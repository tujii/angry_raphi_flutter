import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_event.dart';
import 'package:angry_raphi/features/authentication/presentation/bloc/auth_state.dart';
import 'package:angry_raphi/features/authentication/domain/entities/user_entity.dart';
import 'package:angry_raphi/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:angry_raphi/features/authentication/domain/usecases/sign_out.dart';
import 'package:angry_raphi/features/authentication/domain/usecases/get_current_user.dart';
import 'package:angry_raphi/features/authentication/domain/repositories/auth_repository.dart';
import 'package:angry_raphi/core/errors/failures.dart';

@GenerateMocks([
  SignInWithGoogle,
  SignOut,
  GetCurrentUser,
  AuthRepository,
])
import 'auth_bloc_test.mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignOut mockSignOut;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockAuthRepository mockAuthRepository;

  final tUser = UserEntity(
    id: '1',
    email: 'test@example.com',
    displayName: 'Test User',
    photoURL: null,
    isAdmin: false,
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignOut = MockSignOut();
    mockGetCurrentUser = MockGetCurrentUser();
    mockAuthRepository = MockAuthRepository();

    // Mock authStateChanges to return empty stream by default
    when(mockAuthRepository.authStateChanges).thenAnswer((_) => Stream.value(null));
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state should be AuthInitial', () {
      authBloc = AuthBloc(
        mockSignInWithGoogle,
        mockSignOut,
        mockGetCurrentUser,
        mockAuthRepository,
      );
      
      expect(authBloc.state, equals(AuthInitial()));
    });

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthAuthenticated] when AuthStarted is added and user is authenticated',
      build: () {
        when(mockGetCurrentUser()).thenAnswer((_) async => Right(tUser));
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => Stream.value(null));
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
        AuthAuthenticated(tUser),
      ],
      verify: (_) {
        verify(mockGetCurrentUser()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthUnauthenticated] when AuthStarted is added and user is null',
      build: () {
        when(mockGetCurrentUser()).thenAnswer((_) async => const Right(null));
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => Stream.value(null));
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
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthUnauthenticated] when AuthStarted is added and getCurrentUser fails',
      build: () {
        when(mockGetCurrentUser()).thenAnswer(
          (_) async => const Left(AuthFailure('Failed to get user')),
        );
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => Stream.value(null));
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
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthAuthenticated] when AuthSignInRequested is successful',
      build: () {
        when(mockSignInWithGoogle()).thenAnswer((_) async => Right(tUser));
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => Stream.value(null));
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
        AuthAuthenticated(tUser),
      ],
      verify: (_) {
        verify(mockSignInWithGoogle()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when AuthSignInRequested fails',
      build: () {
        when(mockSignInWithGoogle()).thenAnswer(
          (_) async => const Left(AuthFailure('Sign in failed')),
        );
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => Stream.value(null));
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
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthUnauthenticated] when AuthSignOutRequested is successful',
      build: () {
        when(mockSignOut()).thenAnswer((_) async => const Right(null));
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => Stream.value(null));
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
      'should emit [AuthLoading, AuthError] when AuthSignOutRequested fails',
      build: () {
        when(mockSignOut()).thenAnswer(
          (_) async => const Left(AuthFailure('Sign out failed')),
        );
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => Stream.value(null));
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
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthAuthenticated] when AuthUserChanged is added with non-null user',
      build: () {
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => Stream.value(null));
        return AuthBloc(
          mockSignInWithGoogle,
          mockSignOut,
          mockGetCurrentUser,
          mockAuthRepository,
        );
      },
      act: (bloc) => bloc.add(AuthUserChanged(tUser)),
      expect: () => [
        AuthAuthenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthUnauthenticated] when AuthUserChanged is added with null user',
      build: () {
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => Stream.value(null));
        return AuthBloc(
          mockSignInWithGoogle,
          mockSignOut,
          mockGetCurrentUser,
          mockAuthRepository,
        );
      },
      act: (bloc) => bloc.add(AuthUserChanged(null)),
      expect: () => [
        AuthUnauthenticated(),
      ],
    );
  });
}
