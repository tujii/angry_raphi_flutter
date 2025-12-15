import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:angry_raphi/features/admin/domain/usecases/add_admin.dart';
import 'package:angry_raphi/features/admin/domain/repositories/admin_repository.dart';
import 'package:angry_raphi/core/errors/failures.dart';

import 'add_admin_test.mocks.dart';

@GenerateMocks([AdminRepository])
void main() {
  group('AddAdmin', () {
    late AddAdmin usecase;
    late MockAdminRepository mockRepository;

    setUp(() {
      mockRepository = MockAdminRepository();
      usecase = AddAdmin(mockRepository);
    });

    const String testUserId = 'test_user_id';
    const String testEmail = 'test@example.com';
    const String testDisplayName = 'Test Admin';

    test('should return Right(null) when repository call succeeds', () async {
      // Arrange
      when(mockRepository.addAdmin(testUserId, testEmail, testDisplayName))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase.call(
        userId: testUserId,
        email: testEmail,
        displayName: testDisplayName,
      );

      // Assert
      expect(result, equals(const Right<Failure, void>(null)));
      verify(mockRepository.addAdmin(testUserId, testEmail, testDisplayName))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
        'should return Left(ServerFailure) when repository call fails with ServerFailure',
        () async {
      // Arrange
      const failure = ServerFailure('Failed to add admin');
      when(mockRepository.addAdmin(testUserId, testEmail, testDisplayName))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase.call(
        userId: testUserId,
        email: testEmail,
        displayName: testDisplayName,
      );

      // Assert
      expect(result, equals(const Left<Failure, void>(failure)));
      verify(mockRepository.addAdmin(testUserId, testEmail, testDisplayName))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
        'should return Left(NetworkFailure) when repository call fails with NetworkFailure',
        () async {
      // Arrange
      const failure = NetworkFailure();
      when(mockRepository.addAdmin(testUserId, testEmail, testDisplayName))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase.call(
        userId: testUserId,
        email: testEmail,
        displayName: testDisplayName,
      );

      // Assert
      expect(result, equals(const Left<Failure, void>(failure)));
      verify(mockRepository.addAdmin(testUserId, testEmail, testDisplayName))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass all parameters correctly to repository', () async {
      // Arrange
      when(mockRepository.addAdmin(testUserId, testEmail, testDisplayName))
          .thenAnswer((_) async => const Right(null));

      // Act
      await usecase.call(
        userId: testUserId,
        email: testEmail,
        displayName: testDisplayName,
      );

      // Assert
      verify(mockRepository.addAdmin(testUserId, testEmail, testDisplayName))
          .called(1);
    });
  });
}
