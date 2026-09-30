import '../../domain/entities/space_invitation_entity.dart';
import '../../domain/entities/space_role.dart';
import 'firestore_date.dart';

class SpaceInvitationModel extends SpaceInvitationEntity {
  const SpaceInvitationModel({
    required super.id,
    required super.spaceId,
    required super.spaceName,
    required super.email,
    required super.role,
    required super.invitedBy,
    required super.createdAt,
    super.status,
  });

  factory SpaceInvitationModel.fromMap(Map<String, dynamic> map, String id) {
    return SpaceInvitationModel(
      id: id,
      spaceId: map['spaceId'] as String? ?? '',
      spaceName: map['spaceName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: SpaceRole.fromString(map['role'] as String?),
      invitedBy: map['invitedBy'] as String? ?? '',
      createdAt: firestoreDate(map['createdAt']),
      status: InvitationStatus.fromString(map['status'] as String?),
    );
  }

  /// Fields written on creation; `createdAt` is set by the data source.
  Map<String, dynamic> toMap() {
    return {
      'spaceId': spaceId,
      'spaceName': spaceName,
      'email': email,
      'role': role.value,
      'invitedBy': invitedBy,
      'status': status.value,
    };
  }
}
