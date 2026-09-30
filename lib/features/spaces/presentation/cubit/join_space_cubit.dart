import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/invite_code_entity.dart';
import '../../domain/repositories/spaces_repository.dart';
import '../../domain/usecases/invite_usecases.dart';
import '../../domain/usecases/watch_membership.dart';

abstract class JoinSpaceState extends Equatable {
  const JoinSpaceState();

  @override
  List<Object?> get props => [];
}

class JoinSpaceLoading extends JoinSpaceState {
  const JoinSpaceLoading();
}

/// The link is unknown, deactivated or expired.
class JoinSpaceInvalid extends JoinSpaceState {
  const JoinSpaceInvalid();
}

/// The link is valid and the user is not yet a member.
class JoinSpaceReady extends JoinSpaceState {
  final InviteCodeEntity invite;
  final bool joining;
  final String? error;

  const JoinSpaceReady(this.invite, {this.joining = false, this.error});

  @override
  List<Object?> get props => [invite, joining, error];
}

/// The user is a member (already or after joining).
class JoinSpaceJoined extends JoinSpaceState {
  final String spaceId;

  const JoinSpaceJoined(this.spaceId);

  @override
  List<Object?> get props => [spaceId];
}

/// Handles `/join/:spaceId/:code`.
class JoinSpaceCubit extends Cubit<JoinSpaceState> {
  final GetInviteCode _getInviteCode;
  final WatchMembership _watchMembership;
  final JoinSpaceWithCode _joinSpaceWithCode;

  JoinSpaceCubit(
    this._getInviteCode,
    this._watchMembership,
    this._joinSpaceWithCode,
  ) : super(const JoinSpaceLoading());

  Future<void> load(String spaceId, String code, String uid) async {
    emit(const JoinSpaceLoading());

    // Members are sent straight to the space. Reading a missing membership
    // is denied by the rules, so a failure also means "not a member".
    final membership = await _watchMembership(spaceId, uid).first;
    final isMember = membership.fold((_) => false, (member) => member != null);
    if (isMember) {
      emit(JoinSpaceJoined(spaceId));
      return;
    }

    final result = await _getInviteCode(spaceId, code);
    emit(result.fold(
      (_) => const JoinSpaceInvalid(),
      (invite) => invite != null && invite.isUsableAt(DateTime.now())
          ? JoinSpaceReady(invite)
          : const JoinSpaceInvalid(),
    ));
  }

  Future<void> join(MemberProfile profile) async {
    final current = state;
    if (current is! JoinSpaceReady || current.joining) return;
    emit(JoinSpaceReady(current.invite, joining: true));
    final result = await _joinSpaceWithCode(current.invite, profile);
    emit(result.fold(
      (failure) => JoinSpaceReady(current.invite, error: failure.message),
      (_) => JoinSpaceJoined(current.invite.spaceId),
    ));
  }
}
