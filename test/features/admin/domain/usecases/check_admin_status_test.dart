import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/admin/domain/repositories/admin_repository.dart';
import 'package:angry_raphi/features/admin/domain/usecases/check_admin_status.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'check_admin_status_test.mocks.dart';

@GenerateMocks([AdminRepository])
void main() {
  late CheckAdminStatus useCase;
  late MockAdminRepository mockAdminRepository;

  setUp(() {
    mockAdminRepository = MockAdminRepository();
    useCase = CheckAdminStatus(mockAdminRepository);
  });

  const tEmail = 'test@example.com';

  group('CheckAdminStatus', () {
    test('should return true when user is an admin', () async {
      // arrange
      when(mockAdminRepository.checkAdminStatus(any))
          .thenAnswer((_) async => const Right(true));

      // act
      final result = await useCase(tEmail);

      // assert
      expect(result, const Right(true));
      verify(mockAdminRepository.checkAdminStatus(tEmail));
      verifyNoMoreInteractions(mockAdminRepository);
    });

    test('should return false when user is not an admin', () async {
      // arrange
      when(mockAdminRepository.checkAdminStatus(any))
          .thenAnswer((_) async => const Right(false));

      // act
      final result = await useCase(tEmail);

      // assert
      expect(result, const Right(false));
      verify(mockAdminRepository.checkAdminStatus(tEmail));
      verifyNoMoreInteractions(mockAdminRepository);
    });

    test('should return ServerFailure when check fails', () async {
      // arrange
      const tFailure = ServerFailure('Failed to check admin status');
      when(mockAdminRepository.checkAdminStatus(any))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await useCase(tEmail);

      // assert
      expect(result, const Left(tFailure));
      verify(mockAdminRepository.checkAdminStatus(tEmail));
      verifyNoMoreInteractions(mockAdminRepository);
    });
  });
}
