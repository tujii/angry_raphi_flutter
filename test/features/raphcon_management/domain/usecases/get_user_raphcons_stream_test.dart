import 'package:angry_raphi/core/enums/raphcon_type.dart';
import 'package:angry_raphi/core/errors/failures.dart';
import 'package:angry_raphi/features/raphcon_management/domain/entities/raphcon_entity.dart';
import 'package:angry_raphi/features/raphcon_management/domain/repositories/raphcons_repository.dart';
import 'package:angry_raphi/features/raphcon_management/domain/usecases/get_user_raphcons_stream.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_user_raphcons_stream_test.mocks.dart';

@GenerateMocks([RaphconsRepository])
void main() {
  late GetUserRaphconsStream useCase;
  late MockRaphconsRepository mockRepository;

  setUp(() {
    mockRepository = MockRaphconsRepository();
    useCase = GetUserRaphconsStream(mockRepository);
  });

  const tUserId = 'user-123';
  final tRaphcon = RaphconEntity(
    id: 'raphcon-1',
    userId: tUserId,
    createdBy: 'creator-1',
    type: RaphconType.mouse,
    createdAt: DateTime(2024, 1, 1),
  );
  final tRaphconList = [tRaphcon];

  group('GetUserRaphconsStream', () {
    test('should return stream of raphcons from repository', () {
      // arrange
      when(mockRepository.getUserRaphconsStream(any))
          .thenAnswer((_) => Stream.value(Right(tRaphconList)));

      // act
      final result = useCase(tUserId);

      // assert
      expect(result, emits(Right(tRaphconList)));
      verify(mockRepository.getUserRaphconsStream(tUserId));
    });

    test('should return stream with empty list when user has no raphcons', () {
      // arrange
      when(mockRepository.getUserRaphconsStream(any))
          .thenAnswer((_) => Stream.value(const Right([])));

      // act
      final result = useCase(tUserId);

      // assert
      expect(result, emits(const Right(<RaphconEntity>[])));
      verify(mockRepository.getUserRaphconsStream(tUserId));
    });

    test('should return stream with failure when repository fails', () {
      // arrange
      const tFailure = ServerFailure('Failed to fetch raphcons');
      when(mockRepository.getUserRaphconsStream(any))
          .thenAnswer((_) => Stream.value(const Left(tFailure)));

      // act
      final result = useCase(tUserId);

      // assert
      expect(result, emits(const Left(tFailure)));
      verify(mockRepository.getUserRaphconsStream(tUserId));
    });
  });
}
