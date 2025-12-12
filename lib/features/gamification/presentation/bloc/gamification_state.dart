import 'package:equatable/equatable.dart';
import '../../domain/entities/chaos_user_entity.dart';
import '../../domain/entities/story_entity.dart';

/// Base class for gamification states
abstract class GamificationState extends Equatable {
  const GamificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class GamificationInitial extends GamificationState {}

/// Loading state
class GamificationLoading extends GamificationState {}

/// State when hardware fail is added successfully
class HardwareFailAdded extends GamificationState {
  final String message;

  const HardwareFailAdded({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when story is generated successfully
class StoryGenerated extends GamificationState {
  final StoryEntity story;

  const StoryGenerated({required this.story});

  @override
  List<Object?> get props => [story];
}

/// State when user chaos points are loaded
class UserChaosPointsLoaded extends GamificationState {
  final ChaosUserEntity user;

  const UserChaosPointsLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State with combined data for dashboard
class GamificationDashboardState extends GamificationState {
  final ChaosUserEntity user;
  final StoryEntity? latestStory;

  const GamificationDashboardState({
    required this.user,
    this.latestStory,
  });

  @override
  List<Object?> get props => [user, latestStory];
}

/// Error state
class GamificationError extends GamificationState {
  final String message;

  const GamificationError({required this.message});

  @override
  List<Object?> get props => [message];
}
