import 'package:angry_raphi/core/errors/exceptions.dart';
import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/core/network/network_info.dart';
import 'package:angry_raphi/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:angry_raphi/features/admin/data/models/admin_model.dart';
import 'package:angry_raphi/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:angry_raphi/features/admin/domain/entities/admin_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'admin_repository_impl_test.mocks.dart';

@GenerateMocks([AdminRemoteDataSource, NetworkInfo])
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

  const tEmail = 'admin@example.com';
  const tUserId = 'user-123';
  const tDisplayName = 'Admin User';
  final tAdminEntity = AdminModel(
    id: tUserId,
    email: tEmail,
    displayName: tDisplayName,
    createdAt: DateTime(2024, 1, 1),
    isActive: true,
  );

  group('checkAdminStatus', () {
    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.checkAdminStatus(any))
          .thenAnswer((_) async => true);

      // act
      await repository.checkAdminStatus(tEmail);

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return true when user is admin', () async {
        // arrange
        when(mockRemoteDataSource.checkAdminStatus(any))
            .thenAnswer((_) async => true);

        // act
        final result = await repository.checkAdminStatus(tEmail);

        // assert
        verify(mockRemoteDataSource.checkAdminStatus(tEmail));
        expect(result, const Right(true));
      });

      test('should return false when user is not admin', () async {
        // arrange
        when(mockRemoteDataSource.checkAdminStatus(any))
            .thenAnswer((_) async => false);

        // act
        final result = await repository.checkAdminStatus(tEmail);

        // assert
        verify(mockRemoteDataSource.checkAdminStatus(tEmail));
        expect(result, const Right(false));
      });

      test('should return ServerFailure when ServerException is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.checkAdminStatus(any))
            .thenThrow(ServerException('Server error'));

        // act
        final result = await repository.checkAdminStatus(tEmail);

        // assert
        verify(mockRemoteDataSource.checkAdminStatus(tEmail));
        expect(result, const Left(ServerFailure('Server error')));
      });

      test('should return ServerFailure when unexpected error occurs',
          () async {
        // arrange
        when(mockRemoteDataSource.checkAdminStatus(any))
            .thenThrow(Exception('Unexpected'));

        // act
        final result = await repository.checkAdminStatus(tEmail);

        // assert
        verify(mockRemoteDataSource.checkAdminStatus(tEmail));
        expect(result, isA<Left>());
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NetworkFailure when device has no connection',
          () async {
        // act
        final result = await repository.checkAdminStatus(tEmail);

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, const Left(NetworkFailure()));
      });
    });
  });

  group('addAdmin', () {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should add admin successfully', () async {
        // arrange
        when(mockRemoteDataSource.addAdmin(any, any, any))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.addAdmin(tUserId, tEmail, tDisplayName);

        // assert
        verify(mockRemoteDataSource.addAdmin(tUserId, tEmail, tDisplayName));
        expect(result, const Right(null));
      });

      test('should return ServerFailure when ServerException is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.addAdmin(any, any, any))
            .thenThrow(ServerException('Failed to add admin'));

        // act
        final result = await repository.addAdmin(tUserId, tEmail, tDisplayName);

        // assert
        verify(mockRemoteDataSource.addAdmin(tUserId, tEmail, tDisplayName));
        expect(result, const Left(ServerFailure('Failed to add admin')));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NetworkFailure', () async {
        // act
        final result = await repository.addAdmin(tUserId, tEmail, tDisplayName);

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, const Left(NetworkFailure()));
      });
    });
  });

  group('removeAdmin', () {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should remove admin successfully', () async {
        // arrange
        when(mockRemoteDataSource.removeAdmin(any)).thenAnswer((_) async => {});

        // act
        final result = await repository.removeAdmin(tEmail);

        // assert
        verify(mockRemoteDataSource.removeAdmin(tEmail));
        expect(result, const Right(null));
      });

      test('should return ServerFailure when ServerException is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.removeAdmin(any))
            .thenThrow(ServerException('Failed to remove admin'));

        // act
        final result = await repository.removeAdmin(tEmail);

        // assert
        verify(mockRemoteDataSource.removeAdmin(tEmail));
        expect(result, const Left(ServerFailure('Failed to remove admin')));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NetworkFailure', () async {
        // act
        final result = await repository.removeAdmin(tEmail);

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, const Left(NetworkFailure()));
      });
    });
  });

  group('getAllAdmins', () {
    final tAdminList = [tAdminEntity];

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return list of admins successfully', () async {
        // arrange
        when(mockRemoteDataSource.getAllAdmins())
            .thenAnswer((_) async => tAdminList);

        // act
        final result = await repository.getAllAdmins();

        // assert
        verify(mockRemoteDataSource.getAllAdmins());
        expect(result, Right(tAdminList));
      });

      test('should return empty list when no admins exist', () async {
        // arrange
        when(mockRemoteDataSource.getAllAdmins()).thenAnswer((_) async => []);

        // act
        final result = await repository.getAllAdmins();

        // assert
        verify(mockRemoteDataSource.getAllAdmins());
        expect(result.isRight(), true);
        expect(result.fold((l) => null, (r) => r), <AdminEntity>[]);
      });

      test('should return ServerFailure when ServerException is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.getAllAdmins())
            .thenThrow(ServerException('Failed to fetch admins'));

        // act
        final result = await repository.getAllAdmins();

        // assert
        verify(mockRemoteDataSource.getAllAdmins());
        expect(result, const Left(ServerFailure('Failed to fetch admins')));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NetworkFailure', () async {
        // act
        final result = await repository.getAllAdmins();

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, const Left(NetworkFailure()));
      });
    });
  });
}
