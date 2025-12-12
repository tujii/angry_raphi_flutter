import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/raphcon_type.dart';
import '../../domain/entities/hardware_fail_entity.dart';

/// Data model for hardware fail with Firestore serialization
class HardwareFailModel extends HardwareFailEntity {
  const HardwareFailModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.timestamp,
  });

  /// Create model from Firestore document
  factory HardwareFailModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return HardwareFailModel(
      id: snapshot.id,
      userId: data['userId'] as String,
      type: RaphconType.fromString(data['type'] as String),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Create model from entity
  factory HardwareFailModel.fromEntity(HardwareFailEntity entity) {
    return HardwareFailModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      timestamp: entity.timestamp,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.value,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
