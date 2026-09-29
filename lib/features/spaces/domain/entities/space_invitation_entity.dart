import 'package:equatable/equatable.dart';

import 'space_role.dart';

enum InvitationStatus {
  pending('pending'),
  accepted('accepted'),
  declined('declined'),
  revoked('revoked');

  const InvitationStatus(this.value);

  final String value;

  static InvitationStatus fromString(String? value) {
    return InvitationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => InvitationStatus.pending,
    );
  }
}

/// Invitation of an email address into a space.
///
/// Stored at `invitations/{invitationId}`. Accepting happens server-side
/// (Cloud Function), because the invitee is not yet allowed to write
/// membership documents.
class SpaceInvitationEntity extends Equatable {
  final String id;
  final String spaceId;
  final String spaceName;

  /// Lower-cased email of the invitee
  final String email;
  final SpaceRole role;
  final String invitedBy;
  final DateTime createdAt;
  final InvitationStatus status;

  const SpaceInvitationEntity({
    required this.id,
    required this.spaceId,
    required this.spaceName,
    required this.email,
    required this.role,
    required this.invitedBy,
    required this.createdAt,
    this.status = InvitationStatus.pending,
  });

  @override
  List<Object?> get props =>
      [id, spaceId, spaceName, email, role, invitedBy, createdAt, status];
}
