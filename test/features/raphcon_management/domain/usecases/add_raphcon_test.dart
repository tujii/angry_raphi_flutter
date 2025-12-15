import 'package:angry_raphi/core/enums/raphcon_type.dart';
import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/raphcon_management/domain/repositories/raphcons_repository.dart';
import 'package:angry_raphi/features/raphcon_management/domain/usecases/add_raphcon.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'add_raphcon_test.mocks.dart';

@GenerateMocks([RaphconsRepository])
void main() {
  late AddRaphcon useCase;
  late MockRaphconsRepository mockRepository;

  setUp(() {
    mockRepository = MockRaphconsRepository();
    useCase = AddRaphcon(mockRepository);
  });

  final tParams = AddRaphconParams(
    userId: 'user-123',
    createdBy: 'creator-456',
    comment: 'Test comment',
    type: RaphconType.gold,
  );

  group('AddRaphcon', () {
    test('should add raphcon successfully', () async {
      // arrange
      when(mockRepository.addRaphcon(any))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result, const Right(null));
      verify(mockRepository.addRaphcon(tParams));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when adding raphcon fails', () async {
      // arrange
      const tFailure = ServerFailure(message: 'Failed to add raphcon');
      when(mockRepository.addRaphcon(any))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(mockRepository.addRaphcon(tParams));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should work with default raphcon type', () async {
      // arrange
      final paramsWithDefaultType = AddRaphconParams(
        userId: 'user-123',
        createdBy: 'creator-456',
      );
      when(mockRepository.addRaphcon(any))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase(paramsWithDefaultType);

      // assert
      expect(result, const Right(null));
      verify(mockRepository.addRaphcon(paramsWithDefaultType));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should work without comment', () async {
      // arrange
      final paramsWithoutComment = AddRaphconParams(
        userId: 'user-123',
        createdBy: 'creator-456',
        type: RaphconType.silver,
      );
      when(mockRepository.addRaphcon(any))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase(paramsWithoutComment);

      // assert
      expect(result, const Right(null));
      verify(mockRepository.addRaphcon(paramsWithoutComment));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
