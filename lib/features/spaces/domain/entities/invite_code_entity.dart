import 'package:equatable/equatable.dart';

import 'space_role.dart';

/// Invite link of a space.
///
/// Stored at `spaces/{spaceId}/inviteCodes/{code}`. The code is a long random
/// id and acts as the secret of the link `/join/{spaceId}/{code}`.
class InviteCodeEntity extends Equatable {
  final String code;
  final String spaceId;
  final String spaceName;
  final SpaceRole role;
  final String createdBy;
  final DateTime createdAt;

  /// `null` if the link never expires
  final DateTime? expiresAt;
  final bool active;

  const InviteCodeEntity({
    required this.code,
    required this.spaceId,
    required this.spaceName,
    required this.role,
    required this.createdBy,
    required this.createdAt,
    this.expiresAt,
    this.active = true,
  });

  /// Whether the link can still be used at [now]
  bool isUsableAt(DateTime now) {
    final expiry = expiresAt;
    return active && (expiry == null || expiry.isAfter(now));
  }

  @override
  List<Object?> get props =>
      [code, spaceId, spaceName, role, createdBy, createdAt, expiresAt, active];
}
