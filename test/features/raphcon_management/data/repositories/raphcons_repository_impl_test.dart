import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:angry_raphi/features/raphcon_management/data/repositories/raphcons_repository_impl.dart';
import 'package:angry_raphi/features/raphcon_management/data/datasources/raphcons_remote_datasource.dart';
import 'package:angry_raphi/features/raphcon_management/domain/entities/raphcon_entity.dart';
import 'package:angry_raphi/features/raphcon_management/domain/repositories/raphcons_repository.dart';
import 'package:angry_raphi/core/network/network_info.dart';
import 'package:angry_raphi/core/errors/exceptions.dart';
import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/core/enums/raphcon_type.dart';

@GenerateMocks([RaphconsRemoteDataSource, NetworkInfo])
import 'raphcons_repository_impl_test.mocks.dart';

void main() {
  late RaphconsRepositoryImpl repository;
  late MockRaphconsRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  final tRaphcon = RaphconEntity(
    id: '1',
    userId: 'user123',
    createdBy: 'admin123',
    comment: 'Test comment',
    type: RaphconType.other,
    createdAt: DateTime.now(),
  );

  final tRaphconList = [tRaphcon];

  setUp(() {
    mockRemoteDataSource = MockRaphconsRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = RaphconsRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getUserRaphcons', () {
    const tUserId = 'user123';

    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserRaphcons(any))
          .thenAnswer((_) async => tRaphconList);

      // act
      await repository.getUserRaphcons(tUserId);

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return list of raphcons when successful', () async {
        // arrange
        when(mockRemoteDataSource.getUserRaphcons(tUserId))
            .thenAnswer((_) async => tRaphconList);

        // act
        final result = await repository.getUserRaphcons(tUserId);

        // assert
        verify(mockRemoteDataSource.getUserRaphcons(tUserId));
        expect(result, equals(Right(tRaphconList)));
      });

      test('should return ServerFailure when ServerException is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.getUserRaphcons(tUserId))
            .thenThrow(ServerException('Server error'));

        // act
        final result = await repository.getUserRaphcons(tUserId);

        // assert
        expect(result, equals(const Left(ServerFailure('Server error'))));
      });

      test('should return ServerFailure when unexpected exception is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.getUserRaphcons(tUserId))
            .thenThrow(Exception('Unexpected error'));

        // act
        final result = await repository.getUserRaphcons(tUserId);

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
        final result = await repository.getUserRaphcons(tUserId);

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(const Left(NetworkFailure())));
      });
    });
  });

  group('getUserRaphconsByType', () {
    const tUserId = 'user123';
    const tType = RaphconType.positive;

    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserRaphconsByType(any, any))
          .thenAnswer((_) async => tRaphconList);

      // act
      await repository.getUserRaphconsByType(tUserId, tType);

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return filtered list of raphcons when successful', () async {
        // arrange
        when(mockRemoteDataSource.getUserRaphconsByType(tUserId, tType))
            .thenAnswer((_) async => tRaphconList);

        // act
        final result = await repository.getUserRaphconsByType(tUserId, tType);

        // assert
        verify(mockRemoteDataSource.getUserRaphconsByType(tUserId, tType));
        expect(result, equals(Right(tRaphconList)));
      });

      test('should return ServerFailure when ServerException is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.getUserRaphconsByType(tUserId, tType))
            .thenThrow(ServerException('Server error'));

        // act
        final result = await repository.getUserRaphconsByType(tUserId, tType);

        // assert
        expect(result, equals(const Left(ServerFailure('Server error'))));
      });
    });

    group('device is offline', () {
      test('should return NetworkFailure when device is offline', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.getUserRaphconsByType(tUserId, tType);

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(const Left(NetworkFailure())));
      });
    });
  });

  group('getAllRaphcons', () {
    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getAllRaphcons())
          .thenAnswer((_) async => tRaphconList);

      // act
      await repository.getAllRaphcons();

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return all raphcons when successful', () async {
        // arrange
        when(mockRemoteDataSource.getAllRaphcons())
            .thenAnswer((_) async => tRaphconList);

        // act
        final result = await repository.getAllRaphcons();

        // assert
        verify(mockRemoteDataSource.getAllRaphcons());
        expect(result, equals(Right(tRaphconList)));
      });

      test('should return ServerFailure when ServerException is thrown',
          () async {
        // arrange
        when(mockRemoteDataSource.getAllRaphcons())
            .thenThrow(ServerException('Server error'));

        // act
        final result = await repository.getAllRaphcons();

        // assert
        expect(result, equals(const Left(ServerFailure('Server error'))));
      });
    });

    group('device is offline', () {
      test('should return NetworkFailure when device is offline', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.getAllRaphcons();

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(const Left(NetworkFailure())));
      });
    });
  });
}
