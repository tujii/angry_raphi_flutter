import '../../domain/entities/raphcon_entity.dart';
import '../../../../core/enums/raphcon_type.dart';

class RaphconModel extends RaphconEntity {
  const RaphconModel({
    required super.id,
    required super.userId,
    required super.createdBy,
    required super.createdAt,
    super.comment,
    super.type = RaphconType.other,
  });

  factory RaphconModel.fromMap(Map<String, dynamic> map, String id) {
    return RaphconModel(
      id: id,
      userId: map['userId'] as String,
      createdBy: map['createdBy'] as String,
      createdAt: (map['createdAt'] as dynamic).toDate(),
      comment: map['comment'] as String?,
      type: RaphconType.fromString(map['type'] as String? ?? 'other'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'comment': comment,
      'type': type.value,
    };
  }

  factory RaphconModel.fromEntity(RaphconEntity entity) {
    return RaphconModel(
      id: entity.id,
      userId: entity.userId,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      comment: entity.comment,
      type: entity.type,
    );
  }
}
