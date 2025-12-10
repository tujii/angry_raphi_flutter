import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/user_usecases.dart';

// Events
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUsersEvent extends UserEvent {}

class StartUsersStreamEvent extends UserEvent {}

class StopUsersStreamEvent extends UserEvent {}

class UsersStreamUpdatedEvent extends UserEvent {
  final List<User> users;

  const UsersStreamUpdatedEvent(this.users);

  @override
  List<Object> get props => [users];
}

class AddSampleDataEvent extends UserEvent {}

class RefreshUsersEvent extends UserEvent {}

class AddUserEvent extends UserEvent {
  final String initials;

  const AddUserEvent({
    required this.initials,
  });

  @override
  List<Object> get props => [initials];
}

class DeleteUserEvent extends UserEvent {
  final String userId;

  const DeleteUserEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

// States
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;

  const UserLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}

class SampleDataAdded extends UserState {}

// BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUsersUseCase _getUsersUseCase;
  final GetUsersStreamUseCase _getUsersStreamUseCase;
  final AddUserUseCase _addUserUseCase;

  StreamSubscription<List<User>>? _usersStreamSubscription;

  UserBloc({
    required GetUsersUseCase getUsersUseCase,
    required GetUsersStreamUseCase getUsersStreamUseCase,
    required AddUserUseCase addUserUseCase,
  })  : _getUsersUseCase = getUsersUseCase,
        _getUsersStreamUseCase = getUsersStreamUseCase,
        _addUserUseCase = addUserUseCase,
        super(UserInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<StartUsersStreamEvent>(_onStartUsersStream);
    on<StopUsersStreamEvent>(_onStopUsersStream);
    on<UsersStreamUpdatedEvent>(_onUsersStreamUpdated);
    on<RefreshUsersEvent>(_onRefreshUsers);
    on<AddUserEvent>(_onAddUser);
    on<DeleteUserEvent>(_onDeleteUser);

    // Start the stream automatically
    add(StartUsersStreamEvent());
  }

  Future<void> _onLoadUsers(
      LoadUsersEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final users = await _getUsersUseCase.execute();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError('loadingUsers: ${e.toString()}'));
    }
  }

  Future<void> _onStartUsersStream(
      StartUsersStreamEvent event, Emitter<UserState> emit) async {
    await _usersStreamSubscription?.cancel();

    emit(UserLoading());

    _usersStreamSubscription = _getUsersStreamUseCase.execute().listen(
      (users) {
        add(UsersStreamUpdatedEvent(users));
      },
      onError: (error) {
        emit(UserError('streamError: ${error.toString()}'));
      },
    );
  }

  Future<void> _onStopUsersStream(
      StopUsersStreamEvent event, Emitter<UserState> emit) async {
    await _usersStreamSubscription?.cancel();
    _usersStreamSubscription = null;
  }

  void _onUsersStreamUpdated(
      UsersStreamUpdatedEvent event, Emitter<UserState> emit) {
    emit(UserLoaded(event.users));
  }

  Future<void> _onRefreshUsers(
      RefreshUsersEvent event, Emitter<UserState> emit) async {
    // Restart the stream to get fresh data
    add(StartUsersStreamEvent());
  }

  Future<void> _onAddUser(AddUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final newUser = User(
        id: '', // Firestore will generate the ID
        initials: event.initials,
        raphconCount: 0,
        createdAt: DateTime.now(),
      );

      final success = await _addUserUseCase.execute(newUser);

      if (success) {
        // Reload users to show the new user
        add(LoadUsersEvent());
      } else {
        emit(const UserError('failedToAddUser'));
      }
    } catch (e) {
      emit(UserError('failedToAddUser: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteUser(
      DeleteUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      // TODO: Implement actual user deletion with repository
      // For now, just show a message and reload users
      emit(const UserError('deleteUser'));
      add(LoadUsersEvent());
    } catch (e) {
      emit(UserError('failedToDeleteUser: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _usersStreamSubscription?.cancel();
    return super.close();
  }
}
