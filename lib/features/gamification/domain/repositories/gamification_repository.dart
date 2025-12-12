import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hardware_fail_entity.dart';
import '../entities/story_entity.dart';
import '../entities/chaos_user_entity.dart';
import '../../../../core/enums/raphcon_type.dart';

/// Repository interface for gamification operations
abstract class GamificationRepository {
  /// Add a hardware fail and update chaos points atomically
  Future<Either<Failure, void>> addHardwareFail({
    required String userId,
    required RaphconType type,
  });

  /// Get hardware fails for a user within a date range
  Future<Either<Failure, List<HardwareFailEntity>>> getHardwareFails({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Generate and save a story for a user
  Future<Either<Failure, StoryEntity>> generateUserStory({
    required String userId,
  });

  /// Get the latest story for a user
  Future<Either<Failure, StoryEntity?>> getLatestStory({
    required String userId,
  });

  /// Get user chaos points and rank
  Future<Either<Failure, ChaosUserEntity>> getUserChaosPoints({
    required String userId,
  });

  /// Stream of user chaos points updates
  Stream<Either<Failure, ChaosUserEntity>> getUserChaosPointsStream({
    required String userId,
  });

  /// Stream of latest story updates
  Stream<Either<Failure, StoryEntity?>> getLatestStoryStream({
    required String userId,
  });
}
