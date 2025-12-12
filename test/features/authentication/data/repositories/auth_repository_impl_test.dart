import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:angry_raphi/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:angry_raphi/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:angry_raphi/features/authentication/domain/entities/user_entity.dart';
import 'package:angry_raphi/core/network/network_info.dart';
import 'package:angry_raphi/core/errors/exceptions.dart';
import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/authentication/data/models/user_model.dart';

@GenerateMocks([AuthRemoteDataSource, NetworkInfo])
import 'auth_repository_impl_test.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  final tUserModel = UserModel(
    id: '1',
    email: 'test@example.com',
    displayName: 'Test User',
    photoURL: null,
    isAdmin: false,
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('signInWithGoogle', () {
    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.signInWithGoogle())
          .thenAnswer((_) async => tUserModel);

      // act
      await repository.signInWithGoogle();

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return UserEntity when sign in is successful', () async {
        // arrange
        when(mockRemoteDataSource.signInWithGoogle())
            .thenAnswer((_) async => tUserModel);

        // act
        final result = await repository.signInWithGoogle();

        // assert
        verify(mockRemoteDataSource.signInWithGoogle());
        expect(result, equals(Right(tUserModel)));
      });

      test('should return AuthFailure when AuthException is thrown', () async {
        // arrange
        when(mockRemoteDataSource.signInWithGoogle())
            .thenThrow(AuthException('Sign in failed'));

        // act
        final result = await repository.signInWithGoogle();

        // assert
        expect(result, equals(const Left(AuthFailure('Sign in failed'))));
      });

      test('should return ServerFailure when ServerException is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.signInWithGoogle())
            .thenThrow(ServerException('Server error'));

        // act
        final result = await repository.signInWithGoogle();

        // assert
        expect(result, equals(const Left(ServerFailure('Server error'))));
      });

      test('should return AuthFailure when unexpected exception is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.signInWithGoogle())
            .thenThrow(Exception('Unexpected error'));

        // act
        final result = await repository.signInWithGoogle();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<AuthFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });

    group('device is offline', () {
      test('should return NetworkFailure when device is offline', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.signInWithGoogle();

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(const Left(NetworkFailure())));
      });
    });
  });

  group('signOut', () {
    test('should return Right(null) when sign out is successful', () async {
      // arrange
      when(mockRemoteDataSource.signOut()).thenAnswer((_) async => {});

      // act
      final result = await repository.signOut();

      // assert
      verify(mockRemoteDataSource.signOut());
      expect(result, equals(const Right(null)));
    });

    test('should return AuthFailure when AuthException is thrown', () async {
      // arrange
      when(mockRemoteDataSource.signOut())
          .thenThrow(AuthException('Sign out failed'));

      // act
      final result = await repository.signOut();

      // assert
      expect(result, equals(const Left(AuthFailure('Sign out failed'))));
    });

    test('should return AuthFailure when unexpected exception is thrown',
        () async {
      // arrange
      when(mockRemoteDataSource.signOut())
          .thenThrow(Exception('Unexpected error'));

      // act
      final result = await repository.signOut();

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('getCurrentUser', () {
    test('should return UserEntity when current user exists', () async {
      // arrange
      when(mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => tUserModel);

      // act
      final result = await repository.getCurrentUser();

      // assert
      verify(mockRemoteDataSource.getCurrentUser());
      expect(result, equals(Right(tUserModel)));
    });

    test('should return null when no current user', () async {
      // arrange
      when(mockRemoteDataSource.getCurrentUser()).thenAnswer((_) async => null);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, equals(const Right(null)));
    });

    test('should return AuthFailure when AuthException is thrown', () async {
      // arrange
      when(mockRemoteDataSource.getCurrentUser())
          .thenThrow(AuthException('Get user failed'));

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, equals(const Left(AuthFailure('Get user failed'))));
    });

    test('should return AuthFailure when unexpected exception is thrown',
        () async {
      // arrange
      when(mockRemoteDataSource.getCurrentUser())
          .thenThrow(Exception('Unexpected error'));

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('authStateChanges', () {
    test('should return stream of user changes from remote data source',
        () async {
      // arrange
      final userStream = Stream.value(tUserModel);
      when(mockRemoteDataSource.authStateChanges).thenAnswer((_) => userStream);

      // act
      final result = repository.authStateChanges;

      // assert
      expect(result, equals(userStream));
    });
  });
}
