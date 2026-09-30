import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/invite_code_entity.dart';
import '../../domain/entities/space_invitation_entity.dart';
import '../../domain/entities/space_member_entity.dart';
import '../../domain/entities/space_role.dart';
import '../../domain/usecases/invite_by_email.dart';
import '../../domain/usecases/invite_usecases.dart';
import '../../domain/usecases/remove_member.dart';
import '../../domain/usecases/update_member_role.dart';
import '../../domain/usecases/watch_space_members.dart';

class SpaceAdminState extends Equatable {
  /// `null` while loading
  final List<SpaceMemberEntity>? members;

  /// Active invite links; empty for users who cannot manage members
  final List<InviteCodeEntity> inviteCodes;

  /// Pending email invitations; empty for users who cannot manage members
  final List<SpaceInvitationEntity> invitations;
  final String? error;

  const SpaceAdminState({
    this.members,
    this.inviteCodes = const [],
    this.invitations = const [],
    this.error,
  });

  SpaceAdminState copyWith({
    List<SpaceMemberEntity>? members,
    List<InviteCodeEntity>? inviteCodes,
    List<SpaceInvitationEntity>? invitations,
    String? error,
  }) {
    return SpaceAdminState(
      members: members ?? this.members,
      inviteCodes: inviteCodes ?? this.inviteCodes,
      invitations: invitations ?? this.invitations,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [members, inviteCodes, invitations, error];
}

/// Members, invite links and invitations of a space, plus the actions on
/// them. Actions return the failure message, or `null` on success.
class SpaceAdminCubit extends Cubit<SpaceAdminState> {
  final WatchSpaceMembers _watchMembers;
  final WatchInviteCodes _watchInviteCodes;
  final WatchSpaceInvitations _watchInvitations;
  final UpdateMemberRole _updateMemberRole;
  final RemoveMember _removeMember;
  final CreateInviteLink _createInviteLink;
  final DeactivateInviteCode _deactivateInviteCode;
  final InviteByEmail _inviteByEmail;
  final RevokeInvitation _revokeInvitation;
  final DeleteSpace _deleteSpace;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  SpaceMemberEntity? _actor;

  SpaceAdminCubit({
    required WatchSpaceMembers watchMembers,
    required WatchInviteCodes watchInviteCodes,
    required WatchSpaceInvitations watchInvitations,
    required UpdateMemberRole updateMemberRole,
    required RemoveMember removeMember,
    required CreateInviteLink createInviteLink,
    required DeactivateInviteCode deactivateInviteCode,
    required InviteByEmail inviteByEmail,
    required RevokeInvitation revokeInvitation,
    required DeleteSpace deleteSpace,
  })  : _watchMembers = watchMembers,
        _watchInviteCodes = watchInviteCodes,
        _watchInvitations = watchInvitations,
        _updateMemberRole = updateMemberRole,
        _removeMember = removeMember,
        _createInviteLink = createInviteLink,
        _deactivateInviteCode = deactivateInviteCode,
        _inviteByEmail = inviteByEmail,
        _revokeInvitation = revokeInvitation,
        _deleteSpace = deleteSpace,
        super(const SpaceAdminState());

  /// Starts watching for [actor], the membership of the signed-in user.
  /// Calling it again with a changed role re-subscribes as needed.
  void watch(SpaceMemberEntity actor) {
    final previous = _actor;
    _actor = actor;
    if (previous != null &&
        previous.spaceId == actor.spaceId &&
        previous.role.canManageMembers == actor.role.canManageMembers) {
      return;
    }
    _cancel();
    emit(const SpaceAdminState());

    _subscriptions.add(_watchMembers(actor.spaceId).listen((result) {
      result.fold(
        (failure) => emit(state.copyWith(error: failure.message)),
        (members) => emit(state.copyWith(members: members)),
      );
    }));
    // Invite links and invitations are only readable by admins.
    if (actor.role.canManageMembers) {
      _subscriptions.add(_watchInviteCodes(actor.spaceId).listen((result) {
        result.fold(
          (failure) => emit(state.copyWith(error: failure.message)),
          (codes) => emit(state.copyWith(
              inviteCodes: codes.where((code) => code.active).toList())),
        );
      }));
      _subscriptions.add(_watchInvitations(actor.spaceId).listen((result) {
        result.fold(
          (failure) => emit(state.copyWith(error: failure.message)),
          (invitations) => emit(state.copyWith(invitations: invitations)),
        );
      }));
    }
  }

  Future<String?> changeRole(SpaceMemberEntity target, SpaceRole role) => _run(
      () => _updateMemberRole(actor: _actor!, target: target, newRole: role));

  Future<String?> remove(SpaceMemberEntity target) =>
      _run(() => _removeMember(actor: _actor!, target: target));

  /// Leaving the space is removing the own membership.
  Future<String?> leave() =>
      _run(() => _removeMember(actor: _actor!, target: _actor!));

  Future<String?> deactivateLink(InviteCodeEntity invite) =>
      _run(() => _deactivateInviteCode(invite));

  Future<String?> revoke(SpaceInvitationEntity invitation) =>
      _run(() => _revokeInvitation(invitation));

  Future<String?> deleteSpace() => _run(() => _deleteSpace(_actor!));

  /// Returns the new code, or the failure.
  Future<Either<Failure, String>> createLink({
    required String spaceName,
    required SpaceRole role,
    Duration? validFor,
  }) {
    return _createInviteLink(
      actor: _actor!,
      spaceName: spaceName,
      role: role,
      validFor: validFor,
    );
  }

  Future<String?> inviteByEmail({
    required String spaceName,
    required String email,
    required SpaceRole role,
  }) {
    return _run(() => _inviteByEmail(
          actor: _actor!,
          spaceName: spaceName,
          email: email,
          role: role,
        ));
  }

  Future<String?> _run<T>(Future<Either<Failure, T>> Function() action) async {
    final result = await action();
    return result.fold((failure) => failure.message, (_) => null);
  }

  void _cancel() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  @override
  Future<void> close() {
    _cancel();
    return super.close();
  }
}
