import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/space_invitation_entity.dart';
import '../../domain/repositories/spaces_repository.dart';
import '../../domain/usecases/invite_usecases.dart';
import '../../domain/usecases/watch_my_invitations.dart';

/// Pending email invitations of the signed-in user.
///
/// Errors are shown as an empty list: invitations are an optional extra on
/// the spaces overview.
class MyInvitationsCubit extends Cubit<List<SpaceInvitationEntity>> {
  final WatchMyInvitations _watchMyInvitations;
  final AcceptInvitation _acceptInvitation;
  final DeclineInvitation _declineInvitation;
  StreamSubscription<Either<Failure, List<SpaceInvitationEntity>>>?
      _subscription;

  MyInvitationsCubit(
    this._watchMyInvitations,
    this._acceptInvitation,
    this._declineInvitation,
  ) : super(const []);

  void watch(String email) {
    _subscription?.cancel();
    _subscription = _watchMyInvitations(email).listen((result) {
      emit(result.getOrElse(() => const []));
    });
  }

  /// Returns the failure message, or `null` on success.
  Future<String?> accept(
      SpaceInvitationEntity invitation, MemberProfile profile) async {
    final result = await _acceptInvitation(invitation, profile);
    return result.fold((failure) => failure.message, (_) => null);
  }

  /// Returns the failure message, or `null` on success.
  Future<String?> decline(SpaceInvitationEntity invitation) async {
    final result = await _declineInvitation(invitation);
    return result.fold((failure) => failure.message, (_) => null);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
