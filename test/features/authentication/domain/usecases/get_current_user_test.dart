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

  final tUserEntity = UserEntity(
    id: 'test-uid',
    email: 'test@example.com',
    displayName: 'Test User',
    isAdmin: false,
    createdAt: DateTime(2024, 1, 1),
  );

  group('GetCurrentUser', () {
    test('should return UserEntity when user is signed in', () async {
      // arrange
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(tUserEntity));

      // act
      final result = await useCase();

      // assert
      expect(result, Right(tUserEntity));
      verify(mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return null when no user is signed in', () async {
      // arrange
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(null));

      // act
      final result = await useCase();

      // assert
      expect(result, Right(null));
      verify(mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return AuthFailure when getting current user fails', () async {
      // arrange
      const tFailure = AuthFailure('Failed to get current user');
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
