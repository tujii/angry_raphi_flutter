import 'package:angry_raphi/core/errors/exceptions.dart';
import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/core/network/network_info.dart';
import 'package:angry_raphi/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:angry_raphi/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'admin_repository_impl_test.mocks.dart';

@GenerateMocks([AdminRemoteDataSource, NetworkInfo])
void main() {
  group('AdminRepositoryImpl', () {
    late AdminRepositoryImpl repository;
    late MockAdminRemoteDataSource mockRemoteDataSource;
    late MockNetworkInfo mockNetworkInfo;

    setUp(() {
      mockRemoteDataSource = MockAdminRemoteDataSource();
      mockNetworkInfo = MockNetworkInfo();
      repository = AdminRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        networkInfo: mockNetworkInfo,
      );
    });

    group('addAdmin', () {
      const String testUserId = 'test_user_id';
      const String testEmail = 'test@example.com';
      const String testDisplayName = 'Test Admin';

      test(
          'should return Right(null) when addAdmin succeeds with network connection',
          () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.addAdmin(
                testUserId, testEmail, testDisplayName))
            .thenAnswer((_) async => Future.value());

        // Act
        final result =
            await repository.addAdmin(testUserId, testEmail, testDisplayName);

        // Assert
        expect(result, equals(const Right<Failure, void>(null)));
        verify(mockNetworkInfo.isConnected).called(1);
        verify(mockRemoteDataSource.addAdmin(
                testUserId, testEmail, testDisplayName))
            .called(1);
      });

      test(
          'should return Left(ServerFailure) when addAdmin throws ServerException',
          () async {
        // Arrange
        const errorMessage = 'Failed to add admin';
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.addAdmin(
                testUserId, testEmail, testDisplayName))
            .thenThrow(ServerException(errorMessage));

        // Act
        final result =
            await repository.addAdmin(testUserId, testEmail, testDisplayName);

        // Assert
        expect(result,
            equals(const Left<Failure, void>(ServerFailure(errorMessage))));
        verify(mockNetworkInfo.isConnected).called(1);
        verify(mockRemoteDataSource.addAdmin(
                testUserId, testEmail, testDisplayName))
            .called(1);
      });

      test(
          'should return Left(ServerFailure) when addAdmin throws generic exception',
          () async {
        // Arrange
        const errorMessage = 'Generic error';
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.addAdmin(
                testUserId, testEmail, testDisplayName))
            .thenThrow(Exception(errorMessage));

        // Act
        final result =
            await repository.addAdmin(testUserId, testEmail, testDisplayName);

        // Assert
        expect(
            result,
            equals(const Left<Failure, void>(
                ServerFailure('Exception: $errorMessage'))));
        verify(mockNetworkInfo.isConnected).called(1);
        verify(mockRemoteDataSource.addAdmin(
                testUserId, testEmail, testDisplayName))
            .called(1);
      });

      test('should return Left(NetworkFailure) when no network connection',
          () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result =
            await repository.addAdmin(testUserId, testEmail, testDisplayName);

        // Assert
        expect(result, equals(const Left<Failure, void>(NetworkFailure())));
        verify(mockNetworkInfo.isConnected).called(1);
        verifyNever(mockRemoteDataSource.addAdmin(any, any, any));
      });
    });

    group('removeAdmin', () {
      const String testEmail = 'test@example.com';

      test(
          'should return Right(null) when removeAdmin succeeds with network connection',
          () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.removeAdmin(testEmail))
            .thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.removeAdmin(testEmail);

        // Assert
        expect(result, equals(const Right<Failure, void>(null)));
        verify(mockNetworkInfo.isConnected).called(1);
        verify(mockRemoteDataSource.removeAdmin(testEmail)).called(1);
      });

      test(
          'should return Left(ServerFailure) when removeAdmin throws ServerException',
          () async {
        // Arrange
        const errorMessage = 'Failed to remove admin';
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.removeAdmin(testEmail))
            .thenThrow(ServerException(errorMessage));

        // Act
        final result = await repository.removeAdmin(testEmail);

        // Assert
        expect(result,
            equals(const Left<Failure, void>(ServerFailure(errorMessage))));
        verify(mockNetworkInfo.isConnected).called(1);
        verify(mockRemoteDataSource.removeAdmin(testEmail)).called(1);
      });

      test('should return Left(NetworkFailure) when no network connection',
          () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.removeAdmin(testEmail);

        // Assert
        expect(result, equals(const Left<Failure, void>(NetworkFailure())));
        verify(mockNetworkInfo.isConnected).called(1);
        verifyNever(mockRemoteDataSource.removeAdmin(any));
      });
    });

    group('checkAdminStatus', () {
      const String testEmail = 'test@example.com';

      test('should return Right(true) when admin exists and is active',
          () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.checkAdminStatus(testEmail))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.checkAdminStatus(testEmail);

        // Assert
        expect(result, equals(const Right<Failure, bool>(true)));
        verify(mockNetworkInfo.isConnected).called(1);
        verify(mockRemoteDataSource.checkAdminStatus(testEmail)).called(1);
      });

      test('should return Right(false) when admin does not exist', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.checkAdminStatus(testEmail))
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.checkAdminStatus(testEmail);

        // Assert
        expect(result, equals(const Right<Failure, bool>(false)));
        verify(mockNetworkInfo.isConnected).called(1);
        verify(mockRemoteDataSource.checkAdminStatus(testEmail)).called(1);
      });

      test('should return Left(NetworkFailure) when no network connection',
          () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.checkAdminStatus(testEmail);

        // Assert
        expect(result, equals(const Left<Failure, bool>(NetworkFailure())));
        verify(mockNetworkInfo.isConnected).called(1);
        verifyNever(mockRemoteDataSource.checkAdminStatus(any));
      });
    });
  });
}
