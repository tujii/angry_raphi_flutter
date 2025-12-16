import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/admin/domain/repositories/admin_repository.dart';
import 'package:angry_raphi/features/admin/domain/usecases/add_admin.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'add_admin_test.mocks.dart';

@GenerateMocks([AdminRepository])
void main() {
  late AddAdmin usecase;
  late MockAdminRepository mockRepository;

  setUp(() {
    mockRepository = MockAdminRepository();
    usecase = AddAdmin(mockRepository);
  });

  const tUserId = 'user-123';
  const tEmail = 'admin@example.com';
  const tDisplayName = 'Test Admin';

  test('should add admin through repository', () async {
    // arrange
    when(mockRepository.addAdmin(any, any, any))
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(
      userId: tUserId,
      email: tEmail,
      displayName: tDisplayName,
    );

    // assert
    expect(result, const Right(null));
    verify(mockRepository.addAdmin(tUserId, tEmail, tDisplayName));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    const tFailure = ServerFailure('Server error');
    when(mockRepository.addAdmin(any, any, any))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(
      userId: tUserId,
      email: tEmail,
      displayName: tDisplayName,
    );

    // assert
    expect(result, const Left(tFailure));
    verify(mockRepository.addAdmin(tUserId, tEmail, tDisplayName));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return NetworkFailure when no internet connection', () async {
    // arrange
    const tFailure = NetworkFailure();
    when(mockRepository.addAdmin(any, any, any))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(
      userId: tUserId,
      email: tEmail,
      displayName: tDisplayName,
    );

    // assert
    expect(result, const Left(tFailure));
    verify(mockRepository.addAdmin(tUserId, tEmail, tDisplayName));
    verifyNoMoreInteractions(mockRepository);
  });

  group('input validation', () {
    test('should handle valid inputs correctly', () async {
      // arrange
      when(mockRepository.addAdmin(any, any, any))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(
        userId: 'valid-id',
        email: 'valid@email.com',
        displayName: 'Valid Name',
      );

      // assert
      expect(result, const Right(null));
      verify(mockRepository.addAdmin('valid-id', 'valid@email.com', 'Valid Name'));
    });

    test('should pass through empty strings if repository allows', () async {
      // arrange
      when(mockRepository.addAdmin(any, any, any))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(
        userId: '',
        email: '',
        displayName: '',
      );

      // assert
      expect(result, const Right(null));
      verify(mockRepository.addAdmin('', '', ''));
    });
  });

  group('error handling', () {
    test('should handle ServerException from repository', () async {
      // arrange
      const tFailure = ServerFailure('Database connection failed');
      when(mockRepository.addAdmin(any, any, any))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(
        userId: tUserId,
        email: tEmail,
        displayName: tDisplayName,
      );

      // assert
      expect(result, const Left(tFailure));
    });

    test('should handle CacheException from repository', () async {
      // arrange
      const tFailure = CacheFailure();
      when(mockRepository.addAdmin(any, any, any))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(
        userId: tUserId,
        email: tEmail,
        displayName: tDisplayName,
      );

      // assert
      expect(result, const Left(tFailure));
    });
  });

  group('use case call method', () {
    test('should correctly call repository method with named parameters',
        () async {
      // arrange
      when(mockRepository.addAdmin(any, any, any))
          .thenAnswer((_) async => const Right(null));

      // act
      await usecase.call(
        userId: tUserId,
        email: tEmail,
        displayName: tDisplayName,
      );

      // assert
      verify(mockRepository.addAdmin(tUserId, tEmail, tDisplayName)).called(1);
    });

    test('should work with function call operator', () async {
      // arrange
      when(mockRepository.addAdmin(any, any, any))
          .thenAnswer((_) async => const Right(null));

      // act
      await usecase(
        userId: tUserId,
        email: tEmail,
        displayName: tDisplayName,
      );

      // assert
      verify(mockRepository.addAdmin(tUserId, tEmail, tDisplayName)).called(1);
    });
  });
}
