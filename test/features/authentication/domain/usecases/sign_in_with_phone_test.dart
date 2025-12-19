import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:angry_raphi/features/authentication/domain/usecases/sign_in_with_phone.dart';
import 'package:angry_raphi/features/authentication/domain/repositories/auth_repository.dart';
import 'package:angry_raphi/core/errors/failures.dart';

@GenerateMocks([AuthRepository])
import 'sign_in_with_phone_test.mocks.dart';

void main() {
  late SignInWithPhone usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignInWithPhone(mockAuthRepository);
  });

  group('SignInWithPhone', () {
    const testPhoneNumber = '+491234567890';
    const testVerificationId = 'verification123';

    test('should return verificationId from repository', () async {
      // arrange
      when(mockAuthRepository.signInWithPhone(any))
          .thenAnswer((_) async => const Right(testVerificationId));

      // act
      final result = await usecase(testPhoneNumber);

      // assert
      expect(result, const Right(testVerificationId));
      verify(mockAuthRepository.signInWithPhone(testPhoneNumber));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure when repository fails', () async {
      // arrange
      final failure = AuthFailure('Phone verification failed');
      when(mockAuthRepository.signInWithPhone(any))
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(testPhoneNumber);

      // assert
      expect(result, Left(failure));
      verify(mockAuthRepository.signInWithPhone(testPhoneNumber));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should pass correct phone number to repository', () async {
      // arrange
      when(mockAuthRepository.signInWithPhone(any))
          .thenAnswer((_) async => const Right(testVerificationId));

      // act
      await usecase(testPhoneNumber);

      // assert
      verify(mockAuthRepository.signInWithPhone(testPhoneNumber));
    });
  });
}
