import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/authentication/domain/entities/user_entity.dart';
import 'package:angry_raphi/features/authentication/domain/repositories/auth_repository.dart';
import 'package:angry_raphi/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sign_in_with_google_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SignInWithGoogle useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SignInWithGoogle(mockAuthRepository);
  });

  final tUserEntity = UserEntity(
    id: 'test-uid',
    email: 'test@example.com',
    displayName: 'Test User',
    isAdmin: false,
    createdAt: DateTime(2024, 1, 1),
  );

  group('SignInWithGoogle', () {
    test('should return UserEntity when sign in is successful', () async {
      // arrange
      when(mockAuthRepository.signInWithGoogle())
          .thenAnswer((_) async => Right(tUserEntity));

      // act
      final result = await useCase();

      // assert
      expect(result, Right(tUserEntity));
      verify(mockAuthRepository.signInWithGoogle());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return AuthFailure when sign in fails', () async {
      // arrange
      const tFailure = AuthFailure('Sign in failed');
      when(mockAuthRepository.signInWithGoogle())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await useCase();

      // assert
      expect(result, const Left(tFailure));
      verify(mockAuthRepository.signInWithGoogle());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return NetworkFailure when there is no internet connection',
        () async {
      // arrange
      const tFailure = NetworkFailure();
      when(mockAuthRepository.signInWithGoogle())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await useCase();

      // assert
      expect(result, const Left(tFailure));
      verify(mockAuthRepository.signInWithGoogle());
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
