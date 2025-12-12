import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/enums/raphcon_type.dart';
import '../../domain/entities/hardware_fail_entity.dart';
import '../../domain/entities/story_entity.dart';
import '../../domain/entities/chaos_user_entity.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../datasources/gamification_remote_datasource.dart';

/// Implementation of gamification repository
class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  GamificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> addHardwareFail({
    required String userId,
    required RaphconType type,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addHardwareFail(
          userId: userId,
          type: type,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<HardwareFailEntity>>> getHardwareFails({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final fails = await remoteDataSource.getHardwareFails(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        );
        return Right(fails);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, StoryEntity>> generateUserStory({
    required String userId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Get fails from last 7 days
        final endDate = DateTime.now();
        final startDate = endDate.subtract(const Duration(days: 7));

        final fails = await remoteDataSource.getHardwareFails(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        );

        // Generate story text
        final storyText = _generateStoryText(fails);

        // Save story
        final story = await remoteDataSource.createStory(
          userId: userId,
          text: storyText,
        );

        return Right(story);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  String _generateStoryText(List<HardwareFailEntity> fails) {
    if (fails.isEmpty) {
      return 'Alles läuft perfekt! Keine Hardware-Probleme in den letzten 7 Tagen. 🎉';
    }

    // Count fails by type
    final failCounts = <RaphconType, int>{};
    for (final fail in fails) {
      failCounts[fail.type] = (failCounts[fail.type] ?? 0) + 1;
    }

    // Find most problematic hardware
    final sortedFails = failCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topFail = sortedFails.first;
    final hardwareName = _getHardwareName(topFail.key);
    final count = topFail.value;

    // Generate humorous messages
    final messages = [
      '$hardwareName hat $count× aufgegeben. Zeit für ein Upgrade? 🔧',
      '$hardwareName macht wieder Ferien – $count× in 7 Tagen! 🏖️',
      'Dein $hardwareName braucht Urlaub: $count× versagt! 😅',
      '$hardwareName streikt: $count× Probleme diese Woche! ⚠️',
      'Houston, wir haben ein Problem: $hardwareName $count× ausgefallen! 🚀',
    ];

    // Select random message
    final randomIndex = DateTime.now().millisecond % messages.length;
    return messages[randomIndex];
  }

  String _getHardwareName(RaphconType type) {
    switch (type) {
      case RaphconType.webcam:
        return 'Webcam';
      case RaphconType.headset:
        return 'Headset';
      case RaphconType.mouse:
        return 'Maus';
      case RaphconType.keyboard:
        return 'Tastatur';
      case RaphconType.microphone:
        return 'Mikrofon';
      case RaphconType.speakers:
        return 'Lautsprecher';
      case RaphconType.network:
        return 'Netzwerk';
      case RaphconType.software:
        return 'Software';
      case RaphconType.hardware:
        return 'Hardware';
      case RaphconType.other:
        return 'Gerät';
    }
  }

  @override
  Future<Either<Failure, StoryEntity?>> getLatestStory({
    required String userId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final story = await remoteDataSource.getLatestStory(userId: userId);
        return Right(story);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ChaosUserEntity>> getUserChaosPoints({
    required String userId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.getUserChaosPoints(userId: userId);
        // Update rank based on current points
        final updatedUser = ChaosUserEntity(
          userId: user.userId,
          name: user.name,
          totalChaosPoints: user.totalChaosPoints,
          rank: ChaosUserEntity.calculateRank(user.totalChaosPoints),
        );
        return Right(updatedUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Stream<Either<Failure, ChaosUserEntity>> getUserChaosPointsStream({
    required String userId,
  }) async* {
    try {
      await for (final user in remoteDataSource.getUserChaosPointsStream(userId: userId)) {
        final updatedUser = ChaosUserEntity(
          userId: user.userId,
          name: user.name,
          totalChaosPoints: user.totalChaosPoints,
          rank: ChaosUserEntity.calculateRank(user.totalChaosPoints),
        );
        yield Right(updatedUser);
      }
    } on ServerException catch (e) {
      yield Left(ServerFailure(message: e.message));
    }
  }

  @override
  Stream<Either<Failure, StoryEntity?>> getLatestStoryStream({
    required String userId,
  }) async* {
    try {
      await for (final story in remoteDataSource.getLatestStoryStream(userId: userId)) {
        yield Right(story);
      }
    } on ServerException catch (e) {
      yield Left(ServerFailure(message: e.message));
    }
  }
}
