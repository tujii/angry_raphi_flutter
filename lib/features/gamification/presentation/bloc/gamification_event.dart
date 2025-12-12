import 'package:equatable/equatable.dart';
import '../../../../core/enums/raphcon_type.dart';

/// Base class for gamification events
abstract class GamificationEvent extends Equatable {
  const GamificationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to add a hardware fail
class AddHardwareFailEvent extends GamificationEvent {
  final String userId;
  final RaphconType type;

  const AddHardwareFailEvent({
    required this.userId,
    required this.type,
  });

  @override
  List<Object?> get props => [userId, type];
}

/// Event to generate a story for a user
class GenerateStoryEvent extends GamificationEvent {
  final String userId;

  const GenerateStoryEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to load user chaos points
class LoadUserChaosPointsEvent extends GamificationEvent {
  final String userId;

  const LoadUserChaosPointsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to start streaming user chaos points
class StreamUserChaosPointsEvent extends GamificationEvent {
  final String userId;

  const StreamUserChaosPointsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to start streaming latest story
class StreamLatestStoryEvent extends GamificationEvent {
  final String userId;

  const StreamLatestStoryEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
