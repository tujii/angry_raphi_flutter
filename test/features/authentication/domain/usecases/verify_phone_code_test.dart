import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:angry_raphi/features/authentication/domain/usecases/verify_phone_code.dart';
import 'package:angry_raphi/features/authentication/domain/repositories/auth_repository.dart';
import 'package:angry_raphi/features/authentication/domain/entities/user_entity.dart';
import 'package:angry_raphi/core/errors/failures.dart';

@GenerateMocks([AuthRepository])
import 'verify_phone_code_test.mocks.dart';

void main() {
  late VerifyPhoneCode usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = VerifyPhoneCode(mockAuthRepository);
  });

  group('VerifyPhoneCode', () {
    const testVerificationId = 'verification123';
    const testSmsCode = '123456';
    final testDate = DateTime(2024, 1, 1);
    final testUser = UserEntity(
      id: 'user123',
      email: 'test@example.com',
      displayName: 'Test User',
      isAdmin: false,
      createdAt: testDate,
    );

    test('should return user from repository on successful verification', () async {
      // arrange
      when(mockAuthRepository.verifyPhoneCode(any, any))
          .thenAnswer((_) async => Right(testUser));

      // act
      final result = await usecase(testVerificationId, testSmsCode);

      // assert
      expect(result, Right(testUser));
      verify(mockAuthRepository.verifyPhoneCode(testVerificationId, testSmsCode));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure when verification fails', () async {
      // arrange
      final failure = AuthFailure('Invalid verification code');
      when(mockAuthRepository.verifyPhoneCode(any, any))
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(testVerificationId, testSmsCode);

      // assert
      expect(result, Left(failure));
      verify(mockAuthRepository.verifyPhoneCode(testVerificationId, testSmsCode));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should pass correct parameters to repository', () async {
      // arrange
      when(mockAuthRepository.verifyPhoneCode(any, any))
          .thenAnswer((_) async => Right(testUser));

      // act
      await usecase(testVerificationId, testSmsCode);

      // assert
      verify(mockAuthRepository.verifyPhoneCode(testVerificationId, testSmsCode));
    });
  });
}
