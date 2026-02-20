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
  late AddAdmin useCase;
  late MockAdminRepository mockAdminRepository;

  setUp(() {
    mockAdminRepository = MockAdminRepository();
    useCase = AddAdmin(mockAdminRepository);
  });

  const tUserId = 'test-user-id';
  const tEmail = 'admin@example.com';
  const tDisplayName = 'Admin User';

  group('AddAdmin', () {
    test('should add admin successfully', () async {
      // arrange
      when(mockAdminRepository.addAdmin(any, any, any))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase(
        userId: tUserId,
        email: tEmail,
        displayName: tDisplayName,
      );

      // assert
      expect(result, const Right(null));
      verify(mockAdminRepository.addAdmin(tUserId, tEmail, tDisplayName));
      verifyNoMoreInteractions(mockAdminRepository);
    });

    test('should return ServerFailure when adding admin fails', () async {
      // arrange
      const tFailure = ServerFailure(message: 'Failed to add admin');
      when(mockAdminRepository.addAdmin(any, any, any))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await useCase(
        userId: tUserId,
        email: tEmail,
        displayName: tDisplayName,
      );

      // assert
      expect(result, const Left(tFailure));
      verify(mockAdminRepository.addAdmin(tUserId, tEmail, tDisplayName));
      verifyNoMoreInteractions(mockAdminRepository);
    });
  });
}
