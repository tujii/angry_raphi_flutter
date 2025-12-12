import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:angry_raphi/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:angry_raphi/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:angry_raphi/features/admin/domain/entities/admin_entity.dart';
import 'package:angry_raphi/core/network/network_info.dart';
import 'package:angry_raphi/core/errors/exceptions.dart';
import 'package:angry_raphi/core/errors/failures.dart';

@GenerateMocks([AdminRemoteDataSource, NetworkInfo])
import 'admin_repository_impl_test.mocks.dart';

void main() {
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

  group('checkAdminStatus', () {
    const tUserId = 'user123';
    const tIsAdmin = true;

    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.checkAdminStatus(any))
          .thenAnswer((_) async => tIsAdmin);

      // act
      await repository.checkAdminStatus(tUserId);

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return true when user is admin', () async {
        // arrange
        when(mockRemoteDataSource.checkAdminStatus(tUserId))
            .thenAnswer((_) async => true);

        // act
        final result = await repository.checkAdminStatus(tUserId);

        // assert
        verify(mockRemoteDataSource.checkAdminStatus(tUserId));
        expect(result, equals(const Right(true)));
      });

      test('should return false when user is not admin', () async {
        // arrange
        when(mockRemoteDataSource.checkAdminStatus(tUserId))
            .thenAnswer((_) async => false);

        // act
        final result = await repository.checkAdminStatus(tUserId);

        // assert
        expect(result, equals(const Right(false)));
      });

      test('should return ServerFailure when ServerException is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.checkAdminStatus(tUserId))
            .thenThrow(ServerException('Server error'));

        // act
        final result = await repository.checkAdminStatus(tUserId);

        // assert
        expect(result, equals(const Left(ServerFailure('Server error'))));
      });

      test('should return ServerFailure when unexpected exception is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.checkAdminStatus(tUserId))
            .thenThrow(Exception('Unexpected error'));

        // act
        final result = await repository.checkAdminStatus(tUserId);

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });

    group('device is offline', () {
      test('should return NetworkFailure when device is offline', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.checkAdminStatus(tUserId);

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(const Left(NetworkFailure())));
      });
    });
  });

  group('addAdmin', () {
    const tUserId = 'user123';
    const tEmail = 'admin@example.com';
    const tDisplayName = 'Admin User';

    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.addAdmin(any, any, any))
          .thenAnswer((_) async => {});

      // act
      await repository.addAdmin(tUserId, tEmail, tDisplayName);

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return Right(null) when admin is added successfully',
          () async {
        // arrange
        when(mockRemoteDataSource.addAdmin(tUserId, tEmail, tDisplayName))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.addAdmin(tUserId, tEmail, tDisplayName);

        // assert
        verify(mockRemoteDataSource.addAdmin(tUserId, tEmail, tDisplayName));
        expect(result, equals(const Right(null)));
      });

      test('should return ServerFailure when ServerException is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.addAdmin(tUserId, tEmail, tDisplayName))
            .thenThrow(ServerException('Server error'));

        // act
        final result = await repository.addAdmin(tUserId, tEmail, tDisplayName);

        // assert
        expect(result, equals(const Left(ServerFailure('Server error'))));
      });

      test('should return ServerFailure when unexpected exception is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.addAdmin(tUserId, tEmail, tDisplayName))
            .thenThrow(Exception('Unexpected error'));

        // act
        final result = await repository.addAdmin(tUserId, tEmail, tDisplayName);

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });

    group('device is offline', () {
      test('should return NetworkFailure when device is offline', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.addAdmin(tUserId, tEmail, tDisplayName);

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(const Left(NetworkFailure())));
      });
    });
  });

  group('removeAdmin', () {
    const tUserId = 'user123';

    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.removeAdmin(any))
          .thenAnswer((_) async => {});

      // act
      await repository.removeAdmin(tUserId);

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return Right(null) when admin is removed successfully',
          () async {
        // arrange
        when(mockRemoteDataSource.removeAdmin(tUserId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.removeAdmin(tUserId);

        // assert
        verify(mockRemoteDataSource.removeAdmin(tUserId));
        expect(result, equals(const Right(null)));
      });

      test('should return ServerFailure when ServerException is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.removeAdmin(tUserId))
            .thenThrow(ServerException('Server error'));

        // act
        final result = await repository.removeAdmin(tUserId);

        // assert
        expect(result, equals(const Left(ServerFailure('Server error'))));
      });
    });

    group('device is offline', () {
      test('should return NetworkFailure when device is offline', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.removeAdmin(tUserId);

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(const Left(NetworkFailure())));
      });
    });
  });

  group('getAllAdmins', () {
    final tAdmins = [
      AdminEntity(
        userId: '1',
        email: 'admin1@example.com',
        displayName: 'Admin 1',
        createdAt: DateTime.now(),
      ),
      AdminEntity(
        userId: '2',
        email: 'admin2@example.com',
        displayName: 'Admin 2',
        createdAt: DateTime.now(),
      ),
    ];

    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getAllAdmins())
          .thenAnswer((_) async => tAdmins);

      // act
      await repository.getAllAdmins();

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return list of admins when successful', () async {
        // arrange
        when(mockRemoteDataSource.getAllAdmins())
            .thenAnswer((_) async => tAdmins);

        // act
        final result = await repository.getAllAdmins();

        // assert
        verify(mockRemoteDataSource.getAllAdmins());
        expect(result, equals(Right(tAdmins)));
      });

      test('should return ServerFailure when ServerException is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.getAllAdmins())
            .thenThrow(ServerException('Server error'));

        // act
        final result = await repository.getAllAdmins();

        // assert
        expect(result, equals(const Left(ServerFailure('Server error'))));
      });
    });

    group('device is offline', () {
      test('should return NetworkFailure when device is offline', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.getAllAdmins();

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(const Left(NetworkFailure())));
      });
    });
  });
}
