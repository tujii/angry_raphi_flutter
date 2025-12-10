import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/raphcon_entity.dart';
import '../../domain/usecases/add_raphcon.dart';
import '../../domain/usecases/get_user_raphcon_statistics.dart';
import '../../domain/repositories/raphcons_repository.dart';
import '../../../../core/enums/raphcon_type.dart';

// Events
abstract class RaphconEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddRaphconEvent extends RaphconEvent {
  final String userId;
  final String createdBy;
  final String? comment;
  final RaphconType type;

  AddRaphconEvent({
    required this.userId,
    required this.createdBy,
    this.comment,
    this.type = RaphconType.other,
  });

  @override
  List<Object> get props => [userId, createdBy, comment ?? '', type];
}

class LoadUserRaphconsEvent extends RaphconEvent {
  final String userId;

  LoadUserRaphconsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadUserRaphconStatisticsEvent extends RaphconEvent {
  final String userId;

  LoadUserRaphconStatisticsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

// States
abstract class RaphconState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RaphconInitial extends RaphconState {}

class RaphconLoading extends RaphconState {}

class RaphconAdded extends RaphconState {
  final String message;

  RaphconAdded(this.message);

  @override
  List<Object> get props => [message];
}

class UserRaphconsLoaded extends RaphconState {
  final List<RaphconEntity> raphcons;

  UserRaphconsLoaded(this.raphcons);

  @override
  List<Object> get props => [raphcons];
}

class UserRaphconStatisticsLoaded extends RaphconState {
  final Map<RaphconType, int> statistics;

  UserRaphconStatisticsLoaded(this.statistics);

  @override
  List<Object> get props => [statistics];
}

class RaphconError extends RaphconState {
  final String message;

  RaphconError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
@injectable
class RaphconBloc extends Bloc<RaphconEvent, RaphconState> {
  final AddRaphcon _addRaphcon;
  final GetUserRaphconStatistics _getUserRaphconStatistics;

  RaphconBloc(this._addRaphcon, this._getUserRaphconStatistics)
      : super(RaphconInitial()) {
    on<AddRaphconEvent>(_onAddRaphcon);
    on<LoadUserRaphconsEvent>(_onLoadUserRaphcons);
    on<LoadUserRaphconStatisticsEvent>(_onLoadUserRaphconStatistics);
  }

  Future<void> _onAddRaphcon(
    AddRaphconEvent event,
    Emitter<RaphconState> emit,
  ) async {
    emit(RaphconLoading());

    final params = AddRaphconParams(
      userId: event.userId,
      createdBy: event.createdBy,
      comment: event.comment,
      type: event.type,
    );

    final result = await _addRaphcon(params);
    result.fold(
      (failure) => emit(RaphconError(failure.message)),
      (_) => emit(RaphconAdded('raphconCreated')),
    );
  }

  Future<void> _onLoadUserRaphcons(
    LoadUserRaphconsEvent event,
    Emitter<RaphconState> emit,
  ) async {
    emit(RaphconLoading());

    // TODO: Implement when getUserRaphcons use case is created
    emit(UserRaphconsLoaded([]));
  }

  Future<void> _onLoadUserRaphconStatistics(
    LoadUserRaphconStatisticsEvent event,
    Emitter<RaphconState> emit,
  ) async {
    emit(RaphconLoading());

    final result = await _getUserRaphconStatistics(event.userId);
    result.fold(
      (failure) => emit(RaphconError(failure.message)),
      (statistics) => emit(UserRaphconStatisticsLoaded(statistics)),
    );
  }
}
