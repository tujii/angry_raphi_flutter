import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/check_admin_status.dart';
import '../../domain/usecases/add_admin.dart';

// Events
abstract class AdminEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAdminStatusEvent extends AdminEvent {
  final String userId;

  CheckAdminStatusEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class EnsureCurrentUserIsAdminEvent extends AdminEvent {
  final String userId;
  final String email;
  final String displayName;

  EnsureCurrentUserIsAdminEvent({
    required this.userId,
    required this.email,
    required this.displayName,
  });

  @override
  List<Object> get props => [userId, email, displayName];
}

// States
abstract class AdminState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminStatusChecked extends AdminState {
  final bool isAdmin;

  AdminStatusChecked(this.isAdmin);

  @override
  List<Object> get props => [isAdmin];
}

class AdminError extends AdminState {
  final String message;

  AdminError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
@injectable
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final CheckAdminStatus _checkAdminStatus;
  final AddAdmin _addAdmin;

  AdminBloc(
    this._checkAdminStatus,
    this._addAdmin,
  ) : super(AdminInitial()) {
    on<CheckAdminStatusEvent>(_onCheckAdminStatus);
    on<EnsureCurrentUserIsAdminEvent>(_onEnsureCurrentUserIsAdmin);
  }

  Future<void> _onCheckAdminStatus(
    CheckAdminStatusEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    final result = await _checkAdminStatus(event.userId);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (isAdmin) => emit(AdminStatusChecked(isAdmin)),
    );
  }

  Future<void> _onEnsureCurrentUserIsAdmin(
    EnsureCurrentUserIsAdminEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    // First check if user is already admin
    final checkResult = await _checkAdminStatus(event.userId);

    await checkResult.fold(
      (failure) async => emit(AdminError(failure.message)),
      (isAdmin) async {
        if (!isAdmin) {
          // User is not admin, make them admin
          final addResult = await _addAdmin(
            userId: event.userId,
            email: event.email,
            displayName: event.displayName,
          );

          addResult.fold(
            (failure) => emit(AdminError(failure.message)),
            (_) => emit(AdminStatusChecked(true)),
          );
        } else {
          // User is already admin
          emit(AdminStatusChecked(true));
        }
      },
    );
  }
}
