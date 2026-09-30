import '../../domain/entities/space_entity.dart';
import 'firestore_date.dart';

class SpaceModel extends SpaceEntity {
  const SpaceModel({
    required super.id,
    required super.name,
    super.description,
    required super.createdBy,
    required super.createdAt,
  });

  factory SpaceModel.fromMap(Map<String, dynamic> map, String id) {
    return SpaceModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: firestoreDate(map['createdAt']),
    );
  }

  /// Fields written on creation; `createdAt` is set by the data source.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdBy': createdBy,
    };
  }
}
