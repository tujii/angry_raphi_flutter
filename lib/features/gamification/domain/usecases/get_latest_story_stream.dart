import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/story_entity.dart';
import '../repositories/gamification_repository.dart';

/// Use case for streaming latest story
class GetLatestStoryStream {
  final GamificationRepository repository;

  GetLatestStoryStream(this.repository);

  Stream<Either<Failure, StoryEntity?>> call({
    required String userId,
  }) {
    return repository.getLatestStoryStream(userId: userId);
  }
}
