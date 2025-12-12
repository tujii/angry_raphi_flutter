import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chaos_user_entity.dart';
import '../repositories/gamification_repository.dart';

/// Use case for getting user chaos points
class GetUserChaosPoints {
  final GamificationRepository repository;

  GetUserChaosPoints(this.repository);

  Future<Either<Failure, ChaosUserEntity>> call({
    required String userId,
  }) async {
    return await repository.getUserChaosPoints(userId: userId);
  }
}
