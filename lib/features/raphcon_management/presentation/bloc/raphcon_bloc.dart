import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/raphcon_entity.dart';
import '../../domain/usecases/add_raphcon.dart';
import '../../domain/usecases/get_user_raphcon_statistics.dart';
import '../../domain/usecases/get_user_raphcons_by_type.dart';
import '../../domain/usecases/delete_raphcon.dart';
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

class LoadUserRaphconStatisticsEvent extends RaphconEvent {
  final String userId;

  LoadUserRaphconStatisticsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadUserRaphconsByTypeEvent extends RaphconEvent {
  final String userId;
  final RaphconType type;

  LoadUserRaphconsByTypeEvent(this.userId, this.type);

  @override
  List<Object> get props => [userId, type];
}

class DeleteRaphconEvent extends RaphconEvent {
  final String raphconId;

  DeleteRaphconEvent(this.raphconId);

  @override
  List<Object> get props => [raphconId];
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

class RaphconDeleted extends RaphconState {
  final String deletedRaphconId;

  RaphconDeleted(this.deletedRaphconId);

  @override
  List<Object> get props => [deletedRaphconId];
}

class RaphconDeletionError extends RaphconState {
  final String message;

  RaphconDeletionError(this.message);

  @override
  List<Object> get props => [message];
}

class UserRaphconStatisticsLoaded extends RaphconState {
  final Map<RaphconType, int> statistics;

  UserRaphconStatisticsLoaded(this.statistics);

  @override
  List<Object> get props => [statistics];
}

class UserRaphconsByTypeLoaded extends RaphconState {
  final List<RaphconEntity> raphcons;
  final RaphconType type;

  UserRaphconsByTypeLoaded(this.raphcons, this.type);

  @override
  List<Object> get props => [raphcons, type];
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
  final GetUserRaphconsByType _getUserRaphconsByType;
  final DeleteRaphcon _deleteRaphcon;
  final BuildContext? _context;

  RaphconBloc(this._addRaphcon, this._getUserRaphconStatistics,
      this._getUserRaphconsByType, this._deleteRaphcon,
      [@factoryParam this._context])
      : super(RaphconInitial()) {
    on<AddRaphconEvent>(_onAddRaphcon);
    on<LoadUserRaphconStatisticsEvent>(_onLoadUserRaphconStatistics);
    on<LoadUserRaphconsByTypeEvent>(_onLoadUserRaphconsByType);
    on<DeleteRaphconEvent>(_onDeleteRaphcon);
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
      (_) => emit(RaphconAdded(_context != null
          ? AppLocalizations.of(_context!)?.raphconCreated ?? 'Raphcon created'
          : 'Raphcon created')),
    );
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

  Future<void> _onLoadUserRaphconsByType(
    LoadUserRaphconsByTypeEvent event,
    Emitter<RaphconState> emit,
  ) async {
    emit(RaphconLoading());

    final result = await _getUserRaphconsByType(event.userId, event.type);
    result.fold(
      (failure) => emit(RaphconError(failure.message)),
      (raphcons) => emit(UserRaphconsByTypeLoaded(raphcons, event.type)),
    );
  }

  Future<void> _onDeleteRaphcon(
    DeleteRaphconEvent event,
    Emitter<RaphconState> emit,
  ) async {
    emit(RaphconLoading());

    final result = await _deleteRaphcon(event.raphconId);
    result.fold(
      (failure) => emit(RaphconDeletionError(failure.message)),
      (_) => emit(RaphconDeleted(event.raphconId)),
    );
  }
}
