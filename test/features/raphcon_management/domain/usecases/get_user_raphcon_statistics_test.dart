import 'package:angry_raphi/core/enums/raphcon_type.dart';
import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/raphcon_management/domain/entities/raphcon_entity.dart';
import 'package:angry_raphi/features/raphcon_management/domain/repositories/raphcons_repository.dart';
import 'package:angry_raphi/features/raphcon_management/domain/usecases/get_user_raphcon_statistics.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_user_raphcon_statistics_test.mocks.dart';

@GenerateMocks([RaphconsRepository])
void main() {
  late GetUserRaphconStatistics useCase;
  late MockRaphconsRepository mockRepository;

  setUp(() {
    mockRepository = MockRaphconsRepository();
    useCase = GetUserRaphconStatistics(mockRepository);
  });

  const tUserId = 'user-123';

  group('GetUserRaphconStatistics', () {
    test('should return statistics map with correct counts', () async {
      // arrange
      final raphcons = [
        RaphconEntity(
          id: '1',
          userId: tUserId,
          createdBy: 'creator',
          type: RaphconType.mouse,
          createdAt: DateTime(2024, 1, 1),
        ),
        RaphconEntity(
          id: '2',
          userId: tUserId,
          createdBy: 'creator',
          type: RaphconType.mouse,
          createdAt: DateTime(2024, 1, 2),
        ),
        RaphconEntity(
          id: '3',
          userId: tUserId,
          createdBy: 'creator',
          type: RaphconType.keyboard,
          createdAt: DateTime(2024, 1, 3),
        ),
        RaphconEntity(
          id: '4',
          userId: tUserId,
          createdBy: 'creator',
          type: RaphconType.microphone,
          createdAt: DateTime(2024, 1, 4),
        ),
      ];
      when(mockRepository.getUserRaphcons(any))
          .thenAnswer((_) async => Right(raphcons));

      // act
      final result = await useCase(tUserId);

      // assert
      verify(mockRepository.getUserRaphcons(tUserId));
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return Right'),
        (statistics) {
          expect(statistics[RaphconType.mouse], 2);
          expect(statistics[RaphconType.keyboard], 1);
          expect(statistics[RaphconType.microphone], 1);
          expect(statistics.containsKey(RaphconType.other),
              false); // 0 count removed
        },
      );
    });

    test('should return empty map when user has no raphcons', () async {
      // arrange
      when(mockRepository.getUserRaphcons(any))
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await useCase(tUserId);

      // assert
      verify(mockRepository.getUserRaphcons(tUserId));
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return Right'),
        (statistics) {
          expect(statistics.isEmpty, true);
        },
      );
    });

    test('should return statistics for single raphcon type', () async {
      // arrange
      final raphcons = [
        RaphconEntity(
          id: '1',
          userId: tUserId,
          createdBy: 'creator',
          type: RaphconType.mouse,
          createdAt: DateTime(2024, 1, 1),
        ),
        RaphconEntity(
          id: '2',
          userId: tUserId,
          createdBy: 'creator',
          type: RaphconType.mouse,
          createdAt: DateTime(2024, 1, 2),
        ),
        RaphconEntity(
          id: '3',
          userId: tUserId,
          createdBy: 'creator',
          type: RaphconType.mouse,
          createdAt: DateTime(2024, 1, 3),
        ),
      ];
      when(mockRepository.getUserRaphcons(any))
          .thenAnswer((_) async => Right(raphcons));

      // act
      final result = await useCase(tUserId);

      // assert
      verify(mockRepository.getUserRaphcons(tUserId));
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return Right'),
        (statistics) {
          expect(statistics[RaphconType.mouse], 3);
          expect(statistics.length, 1); // Only gold should be present
        },
      );
    });

    test('should return failure when repository fails', () async {
      // arrange
      const tFailure = ServerFailure('Failed to fetch raphcons');
      when(mockRepository.getUserRaphcons(any))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await useCase(tUserId);

      // assert
      verify(mockRepository.getUserRaphcons(tUserId));
      expect(result, const Left(tFailure));
    });

    test('should handle all raphcon types correctly', () async {
      // arrange
      final raphcons = [
        RaphconEntity(
          id: '1',
          userId: tUserId,
          createdBy: 'creator',
          type: RaphconType.mouse,
          createdAt: DateTime(2024, 1, 1),
        ),
        RaphconEntity(
          id: '2',
          userId: tUserId,
          createdBy: 'creator',
          type: RaphconType.keyboard,
          createdAt: DateTime(2024, 1, 2),
        ),
        RaphconEntity(
          id: '3',
          userId: tUserId,
          createdBy: 'creator',
          type: RaphconType.microphone,
          createdAt: DateTime(2024, 1, 3),
        ),
        RaphconEntity(
          id: '4',
          userId: tUserId,
          createdBy: 'creator',
          type: RaphconType.other,
          createdAt: DateTime(2024, 1, 4),
        ),
      ];
      when(mockRepository.getUserRaphcons(any))
          .thenAnswer((_) async => Right(raphcons));

      // act
      final result = await useCase(tUserId);

      // assert
      verify(mockRepository.getUserRaphcons(tUserId));
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return Right'),
        (statistics) {
          expect(statistics[RaphconType.mouse], 1);
          expect(statistics[RaphconType.keyboard], 1);
          expect(statistics[RaphconType.microphone], 1);
          expect(statistics[RaphconType.other], 1);
          expect(statistics.length, 4);
        },
      );
    });
  });
}
