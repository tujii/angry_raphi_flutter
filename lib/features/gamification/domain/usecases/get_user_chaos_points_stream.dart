import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chaos_user_entity.dart';
import '../repositories/gamification_repository.dart';

/// Use case for streaming user chaos points
class GetUserChaosPointsStream {
  final GamificationRepository repository;

  GetUserChaosPointsStream(this.repository);

  Stream<Either<Failure, ChaosUserEntity>> call({
    required String userId,
  }) {
    return repository.getUserChaosPointsStream(userId: userId);
  }
}
