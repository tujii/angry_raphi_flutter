import '../../domain/entities/invite_code_entity.dart';
import '../../domain/entities/space_role.dart';
import 'firestore_date.dart';

class InviteCodeModel extends InviteCodeEntity {
  const InviteCodeModel({
    required super.code,
    required super.spaceId,
    required super.spaceName,
    required super.role,
    required super.createdBy,
    required super.createdAt,
    super.expiresAt,
    super.active,
  });

  factory InviteCodeModel.fromMap(Map<String, dynamic> map, String code) {
    final expiresAt = map['expiresAt'];
    return InviteCodeModel(
      code: code,
      spaceId: map['spaceId'] as String? ?? '',
      spaceName: map['spaceName'] as String? ?? '',
      role: SpaceRole.fromString(map['role'] as String?),
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: firestoreDate(map['createdAt']),
      expiresAt: expiresAt == null ? null : firestoreDate(expiresAt),
      active: map['active'] as bool? ?? false,
    );
  }

  /// Fields written on creation; `createdAt` is set by the data source.
  Map<String, dynamic> toMap() {
    return {
      'spaceId': spaceId,
      'spaceName': spaceName,
      'role': role.value,
      'createdBy': createdBy,
      'expiresAt': expiresAt,
      'active': active,
    };
  }
}
