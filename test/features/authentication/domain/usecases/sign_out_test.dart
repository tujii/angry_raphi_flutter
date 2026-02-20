import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/authentication/domain/repositories/auth_repository.dart';
import 'package:angry_raphi/features/authentication/domain/usecases/sign_out.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sign_out_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SignOut useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SignOut(mockAuthRepository);
  });

  group('SignOut', () {
    test('should call repository signOut and return Right(void) on success',
        () async {
      // arrange
      when(mockAuthRepository.signOut())
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase();

      // assert
      expect(result, const Right(null));
      verify(mockAuthRepository.signOut());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return AuthFailure when sign out fails', () async {
      // arrange
      const tFailure = AuthFailure(message: 'Sign out failed');
      when(mockAuthRepository.signOut())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await useCase();

      // assert
      expect(result, const Left(tFailure));
      verify(mockAuthRepository.signOut());
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
