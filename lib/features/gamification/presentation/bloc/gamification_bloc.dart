import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_hardware_fail.dart';
import '../../domain/usecases/generate_user_story.dart';
import '../../domain/usecases/get_user_chaos_points.dart';
import '../../domain/usecases/get_user_chaos_points_stream.dart';
import '../../domain/usecases/get_latest_story_stream.dart';
import 'gamification_event.dart';
import 'gamification_state.dart';
import '../../domain/entities/chaos_user_entity.dart';
import '../../domain/entities/story_entity.dart';

/// BLoC for managing gamification state
class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final AddHardwareFail addHardwareFailUseCase;
  final GenerateUserStory generateUserStoryUseCase;
  final GetUserChaosPoints getUserChaosPointsUseCase;
  final GetUserChaosPointsStream getUserChaosPointsStreamUseCase;
  final GetLatestStoryStream getLatestStoryStreamUseCase;

  StreamSubscription? _chaosPointsSubscription;
  StreamSubscription? _storySubscription;

  ChaosUserEntity? _currentUser;
  StoryEntity? _currentStory;

  GamificationBloc({
    required this.addHardwareFailUseCase,
    required this.generateUserStoryUseCase,
    required this.getUserChaosPointsUseCase,
    required this.getUserChaosPointsStreamUseCase,
    required this.getLatestStoryStreamUseCase,
  }) : super(GamificationInitial()) {
    on<AddHardwareFailEvent>(_onAddHardwareFail);
    on<GenerateStoryEvent>(_onGenerateStory);
    on<LoadUserChaosPointsEvent>(_onLoadUserChaosPoints);
    on<StreamUserChaosPointsEvent>(_onStreamUserChaosPoints);
    on<StreamLatestStoryEvent>(_onStreamLatestStory);
  }

  Future<void> _onAddHardwareFail(
    AddHardwareFailEvent event,
    Emitter<GamificationState> emit,
  ) async {
    emit(GamificationLoading());

    final result = await addHardwareFailUseCase(
      userId: event.userId,
      type: event.type,
    );

    result.fold(
      (failure) => emit(GamificationError(message: failure.message)),
      (_) async {
        // Generate story automatically after adding fail
        final storyResult = await generateUserStoryUseCase(
          userId: event.userId,
        );

        storyResult.fold(
          (failure) => emit(HardwareFailAdded(
            message: 'Hardware fail added successfully',
          )),
          (story) {
            _currentStory = story;
            emit(HardwareFailAdded(
              message: 'Hardware fail added successfully',
            ));
          },
        );
      },
    );
  }

  Future<void> _onGenerateStory(
    GenerateStoryEvent event,
    Emitter<GamificationState> emit,
  ) async {
    emit(GamificationLoading());

    final result = await generateUserStoryUseCase(
      userId: event.userId,
    );

    result.fold(
      (failure) => emit(GamificationError(message: failure.message)),
      (story) {
        _currentStory = story;
        emit(StoryGenerated(story: story));
      },
    );
  }

  Future<void> _onLoadUserChaosPoints(
    LoadUserChaosPointsEvent event,
    Emitter<GamificationState> emit,
  ) async {
    emit(GamificationLoading());

    final result = await getUserChaosPointsUseCase(
      userId: event.userId,
    );

    result.fold(
      (failure) => emit(GamificationError(message: failure.message)),
      (user) {
        _currentUser = user;
        emit(UserChaosPointsLoaded(user: user));
      },
    );
  }

  Future<void> _onStreamUserChaosPoints(
    StreamUserChaosPointsEvent event,
    Emitter<GamificationState> emit,
  ) async {
    await _chaosPointsSubscription?.cancel();

    _chaosPointsSubscription = getUserChaosPointsStreamUseCase(
      userId: event.userId,
    ).listen((result) {
      result.fold(
        (failure) => emit(GamificationError(message: failure.message)),
        (user) {
          _currentUser = user;
          _emitDashboardState(emit);
        },
      );
    });
  }

  Future<void> _onStreamLatestStory(
    StreamLatestStoryEvent event,
    Emitter<GamificationState> emit,
  ) async {
    await _storySubscription?.cancel();

    _storySubscription = getLatestStoryStreamUseCase(
      userId: event.userId,
    ).listen((result) {
      result.fold(
        (failure) => emit(GamificationError(message: failure.message)),
        (story) {
          _currentStory = story;
          _emitDashboardState(emit);
        },
      );
    });
  }

  void _emitDashboardState(Emitter<GamificationState> emit) {
    if (_currentUser != null) {
      emit(GamificationDashboardState(
        user: _currentUser!,
        latestStory: _currentStory,
      ));
    }
  }

  @override
  Future<void> close() {
    _chaosPointsSubscription?.cancel();
    _storySubscription?.cancel();
    return super.close();
  }
}
