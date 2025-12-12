import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/story_entity.dart';
import '../repositories/gamification_repository.dart';

/// Use case for generating a user story
class GenerateUserStory {
  final GamificationRepository repository;

  GenerateUserStory(this.repository);

  Future<Either<Failure, StoryEntity>> call({
    required String userId,
  }) async {
    return await repository.generateUserStory(userId: userId);
  }
}
