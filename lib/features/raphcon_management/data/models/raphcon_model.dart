import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/enums/raphcon_type.dart';
import '../../domain/entities/raphcon_entity.dart';

class RaphconModel extends RaphconEntity {
  const RaphconModel({
    required super.id,
    required super.userId,
    required super.createdBy,
    required super.createdAt,
    super.comment,
    super.type = RaphconType.other,
    super.isActive = true,
  });

  factory RaphconModel.fromMap(Map<String, dynamic> map, String id) {
    try {
      final createdAtData = map['createdAt'];
      DateTime createdAt;

      if (createdAtData is DateTime) {
        createdAt = createdAtData;
      } else if (createdAtData != null) {
        createdAt = createdAtData.toDate();
      } else {
        createdAt = DateTime.now();
      }

      return RaphconModel(
        id: id,
        userId: map['userId'] as String,
        createdBy: map['createdBy'] as String,
        createdAt: createdAt,
        comment: map['comment'] as String?,
        type: RaphconType.fromString(map['type'] as String? ?? 'other'),
        isActive: map['isActive'] as bool? ?? true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'comment': comment,
      'type': type.value,
      'isActive': isActive,
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
      isActive: entity.isActive,
    );
  }
}
