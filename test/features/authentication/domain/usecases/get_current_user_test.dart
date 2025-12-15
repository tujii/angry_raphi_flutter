import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/authentication/domain/entities/user_entity.dart';
import 'package:angry_raphi/features/authentication/domain/repositories/auth_repository.dart';
import 'package:angry_raphi/features/authentication/domain/usecases/get_current_user.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_current_user_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late GetCurrentUser useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = GetCurrentUser(mockAuthRepository);
  });

  const tUserEntity = UserEntity(
    uid: 'test-uid',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  group('GetCurrentUser', () {
    test('should return UserEntity when user is signed in', () async {
      // arrange
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(tUserEntity));

      // act
      final result = await useCase();

      // assert
      expect(result, const Right(tUserEntity));
      verify(mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return null when no user is signed in', () async {
      // arrange
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase();

      // assert
      expect(result, const Right(null));
      verify(mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return AuthFailure when getting current user fails',
        () async {
      // arrange
      const tFailure = AuthFailure(message: 'Failed to get current user');
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await useCase();

      // assert
      expect(result, const Left(tFailure));
      verify(mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
