import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/raphcon_management/domain/repositories/raphcons_repository.dart';
import 'package:angry_raphi/features/raphcon_management/domain/usecases/delete_raphcon.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'delete_raphcon_test.mocks.dart';

@GenerateMocks([RaphconsRepository])
void main() {
  late DeleteRaphcon useCase;
  late MockRaphconsRepository mockRepository;

  setUp(() {
    mockRepository = MockRaphconsRepository();
    useCase = DeleteRaphcon(mockRepository);
  });

  const tRaphconId = 'raphcon-123';

  group('DeleteRaphcon', () {
    test('should delete raphcon successfully', () async {
      // arrange
      when(mockRepository.deleteRaphcon(any))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase(tRaphconId);

      // assert
      expect(result, const Right(null));
      verify(mockRepository.deleteRaphcon(tRaphconId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when deletion fails', () async {
      // arrange
      const tFailure = ServerFailure('Failed to delete raphcon');
      when(mockRepository.deleteRaphcon(any))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await useCase(tRaphconId);

      // assert
      expect(result, const Left(tFailure));
      verify(mockRepository.deleteRaphcon(tRaphconId));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
