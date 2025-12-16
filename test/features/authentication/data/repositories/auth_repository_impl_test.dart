import 'package:angry_raphi/core/errors/exceptions.dart';
import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/core/network/network_info.dart';
import 'package:angry_raphi/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:angry_raphi/features/authentication/data/models/user_model.dart';
import 'package:angry_raphi/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSource, NetworkInfo])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  final tUserEntity = UserModel(
    id: 'test-uid',
    email: 'test@example.com',
    displayName: 'Test User',
    isAdmin: false,
    createdAt: DateTime(2024, 1, 1),
  );

  group('signInWithGoogle', () {
    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.signInWithGoogle())
          .thenAnswer((_) async => tUserEntity);

      // act
      await repository.signInWithGoogle();

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return UserEntity when sign in succeeds', () async {
        // arrange
        when(mockRemoteDataSource.signInWithGoogle())
            .thenAnswer((_) async => tUserEntity);

        // act
        final result = await repository.signInWithGoogle();

        // assert
        verify(mockRemoteDataSource.signInWithGoogle());
        expect(result, Right(tUserEntity));
      });

      test('should return AuthFailure when AuthException is thrown', () async {
        // arrange
        when(mockRemoteDataSource.signInWithGoogle())
            .thenThrow(AuthException('Sign in cancelled'));

        // act
        final result = await repository.signInWithGoogle();

        // assert
        verify(mockRemoteDataSource.signInWithGoogle());
        expect(result, const Left(AuthFailure('Sign in cancelled')));
      });

      test('should return ServerFailure when ServerException is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.signInWithGoogle())
            .thenThrow(ServerException('Server error'));

        // act
        final result = await repository.signInWithGoogle();

        // assert
        verify(mockRemoteDataSource.signInWithGoogle());
        expect(result, const Left(ServerFailure('Server error')));
      });

      test('should return AuthFailure when unexpected error occurs', () async {
        // arrange
        when(mockRemoteDataSource.signInWithGoogle())
            .thenThrow(Exception('Unexpected'));

        // act
        final result = await repository.signInWithGoogle();

        // assert
        verify(mockRemoteDataSource.signInWithGoogle());
        expect(result, isA<Left>());
        result.fold(
          (failure) => expect(failure, isA<AuthFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NetworkFailure when device has no connection',
          () async {
        // act
        final result = await repository.signInWithGoogle();

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, const Left(NetworkFailure()));
      });
    });
  });

  group('signOut', () {
    test('should return Right(null) when sign out succeeds', () async {
      // arrange
      when(mockRemoteDataSource.signOut()).thenAnswer((_) async => {});

      // act
      final result = await repository.signOut();

      // assert
      verify(mockRemoteDataSource.signOut());
      expect(result, Right(null));
    });

    test('should return AuthFailure when AuthException is thrown', () async {
      // arrange
      when(mockRemoteDataSource.signOut())
          .thenThrow(AuthException('Sign out failed'));

      // act
      final result = await repository.signOut();

      // assert
      verify(mockRemoteDataSource.signOut());
      expect(result, const Left(AuthFailure('Sign out failed')));
    });

    test('should return AuthFailure when unexpected error occurs', () async {
      // arrange
      when(mockRemoteDataSource.signOut()).thenThrow(Exception('Unexpected'));

      // act
      final result = await repository.signOut();

      // assert
      verify(mockRemoteDataSource.signOut());
      expect(result, isA<Left>());
    });
  });

  group('getCurrentUser', () {
    test('should return UserEntity when user is signed in', () async {
      // arrange
      when(mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => tUserEntity);

      // act
      final result = await repository.getCurrentUser();

      // assert
      verify(mockRemoteDataSource.getCurrentUser());
      expect(result, Right(tUserEntity));
    });

    test('should return null when no user is signed in', () async {
      // arrange
      when(mockRemoteDataSource.getCurrentUser()).thenAnswer((_) async => null);

      // act
      final result = await repository.getCurrentUser();

      // assert
      verify(mockRemoteDataSource.getCurrentUser());
      expect(result, Right(null));
    });

    test('should return AuthFailure when AuthException is thrown', () async {
      // arrange
      when(mockRemoteDataSource.getCurrentUser())
          .thenThrow(AuthException('Failed to get user'));

      // act
      final result = await repository.getCurrentUser();

      // assert
      verify(mockRemoteDataSource.getCurrentUser());
      expect(result, const Left(AuthFailure('Failed to get user')));
    });

    test('should return AuthFailure when unexpected error occurs', () async {
      // arrange
      when(mockRemoteDataSource.getCurrentUser())
          .thenThrow(Exception('Unexpected'));

      // act
      final result = await repository.getCurrentUser();

      // assert
      verify(mockRemoteDataSource.getCurrentUser());
      expect(result, isA<Left>());
    });
  });

  group('authStateChanges', () {
    test('should return stream from data source', () {
      // arrange
      final stream = Stream.value(tUserEntity);
      when(mockRemoteDataSource.authStateChanges).thenAnswer((_) => stream);

      // act
      final result = repository.authStateChanges;

      // assert
      expect(result, stream);
      verify(mockRemoteDataSource.authStateChanges);
    });

    test('should handle null user in stream', () {
      // arrange
      final stream = Stream.value(null);
      when(mockRemoteDataSource.authStateChanges).thenAnswer((_) => stream);

      // act
      final result = repository.authStateChanges;

      // assert
      expect(result, emits(null));
      verify(mockRemoteDataSource.authStateChanges);
    });
  });
}
