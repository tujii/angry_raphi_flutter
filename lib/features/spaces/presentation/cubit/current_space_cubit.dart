import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/space_entity.dart';
import '../../domain/entities/space_member_entity.dart';
import '../../domain/usecases/watch_membership.dart';
import '../../domain/usecases/watch_space.dart';

abstract class CurrentSpaceState extends Equatable {
  const CurrentSpaceState();

  @override
  List<Object?> get props => [];
}

class CurrentSpaceLoading extends CurrentSpaceState {
  const CurrentSpaceLoading();
}

/// The user is a member of an existing space.
class CurrentSpaceReady extends CurrentSpaceState {
  final SpaceEntity space;
  final SpaceMemberEntity member;

  const CurrentSpaceReady(this.space, this.member);

  @override
  List<Object?> get props => [space, member];
}

/// The space does not exist or the user is not (or no longer) a member.
class CurrentSpaceNoAccess extends CurrentSpaceState {
  const CurrentSpaceNoAccess();
}

class CurrentSpaceError extends CurrentSpaceState {
  final String message;

  const CurrentSpaceError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Watches the space opened via `/s/:spaceId` together with the membership
/// (and therefore the role) of the signed-in user.
///
/// The space document is only watched while a membership exists, because
/// reading it is denied for non-members.
class CurrentSpaceCubit extends Cubit<CurrentSpaceState> {
  final WatchSpace _watchSpace;
  final WatchMembership _watchMembership;

  StreamSubscription<Either<Failure, SpaceMemberEntity?>>? _memberSubscription;
  StreamSubscription<Either<Failure, SpaceEntity?>>? _spaceSubscription;
  SpaceMemberEntity? _member;
  SpaceEntity? _space;

  CurrentSpaceCubit(this._watchSpace, this._watchMembership)
      : super(const CurrentSpaceLoading());

  void watch(String spaceId, String uid) {
    _cancel();
    emit(const CurrentSpaceLoading());
    _memberSubscription = _watchMembership(spaceId, uid).listen((result) {
      result.fold(
        (failure) => _onNoAccess(),
        (member) {
          if (member == null) {
            _onNoAccess();
            return;
          }
          _member = member;
          if (_spaceSubscription == null) {
            _spaceSubscription = _watchSpace(spaceId).listen(_onSpace);
          } else {
            _emitReady();
          }
        },
      );
    });
  }

  void _onSpace(Either<Failure, SpaceEntity?> result) {
    result.fold(
      (failure) => emit(CurrentSpaceError(failure.message)),
      (space) {
        if (space == null) {
          _onNoAccess();
          return;
        }
        _space = space;
        _emitReady();
      },
    );
  }

  void _emitReady() {
    final space = _space;
    final member = _member;
    if (space != null && member != null) {
      emit(CurrentSpaceReady(space, member));
    }
  }

  void _onNoAccess() {
    _spaceSubscription?.cancel();
    _spaceSubscription = null;
    _space = null;
    _member = null;
    emit(const CurrentSpaceNoAccess());
  }

  void _cancel() {
    _memberSubscription?.cancel();
    _spaceSubscription?.cancel();
    _memberSubscription = null;
    _spaceSubscription = null;
    _space = null;
    _member = null;
  }

  @override
  Future<void> close() async {
    _cancel();
    return super.close();
  }
}
