import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/space_entity.dart';
import '../../domain/usecases/watch_my_spaces.dart';

abstract class MySpacesState extends Equatable {
  const MySpacesState();

  @override
  List<Object?> get props => [];
}

class MySpacesLoading extends MySpacesState {
  const MySpacesLoading();
}

class MySpacesLoaded extends MySpacesState {
  final List<SpaceEntity> spaces;

  const MySpacesLoaded(this.spaces);

  @override
  List<Object?> get props => [spaces];
}

class MySpacesError extends MySpacesState {
  final String message;

  const MySpacesError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Live list of the spaces the signed-in user is a member of.
class MySpacesCubit extends Cubit<MySpacesState> {
  final WatchMySpaces _watchMySpaces;
  StreamSubscription<dynamic>? _subscription;

  MySpacesCubit(this._watchMySpaces) : super(const MySpacesLoading());

  void watch(String uid) {
    _subscription?.cancel();
    emit(const MySpacesLoading());
    _subscription = _watchMySpaces(uid).listen((result) {
      emit(result.fold(
        (failure) => MySpacesError(failure.message),
        MySpacesLoaded.new,
      ));
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
