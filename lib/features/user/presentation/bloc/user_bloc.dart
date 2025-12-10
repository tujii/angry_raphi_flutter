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

class AddSampleDataEvent extends UserEvent {}

class RefreshUsersEvent extends UserEvent {}

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
  final AddSampleDataUseCase _addSampleDataUseCase;

  UserBloc({
    required GetUsersUseCase getUsersUseCase,
    required AddSampleDataUseCase addSampleDataUseCase,
  })  : _getUsersUseCase = getUsersUseCase,
        _addSampleDataUseCase = addSampleDataUseCase,
        super(UserInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<AddSampleDataEvent>(_onAddSampleData);
    on<RefreshUsersEvent>(_onRefreshUsers);
  }

  Future<void> _onLoadUsers(
      LoadUsersEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final users = await _getUsersUseCase.execute();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError('Fehler beim Laden der Benutzer: ${e.toString()}'));
    }
  }

  Future<void> _onAddSampleData(
      AddSampleDataEvent event, Emitter<UserState> emit) async {
    try {
      await _addSampleDataUseCase.execute();
      emit(SampleDataAdded());
      // Reload users after adding sample data
      add(LoadUsersEvent());
    } catch (e) {
      emit(UserError(
          'Fehler beim Hinzufügen der Beispiel-Daten: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshUsers(
      RefreshUsersEvent event, Emitter<UserState> emit) async {
    add(LoadUsersEvent());
  }
}
