import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chaos_user_entity.dart';

/// Data model for chaos user with Firestore serialization
class ChaosUserModel extends ChaosUserEntity {
  const ChaosUserModel({
    required super.userId,
    required super.name,
    required super.totalChaosPoints,
    required super.rank,
  });

  /// Create model from Firestore document
  factory ChaosUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return ChaosUserModel(
      userId: snapshot.id,
      name: data['name'] as String,
      totalChaosPoints: (data['totalChaosPoints'] as int?) ?? 0,
      rank: data['rank'] as String? ?? 'Chaos Beginner',
    );
  }

  /// Create model from entity
  factory ChaosUserModel.fromEntity(ChaosUserEntity entity) {
    return ChaosUserModel(
      userId: entity.userId,
      name: entity.name,
      totalChaosPoints: entity.totalChaosPoints,
      rank: entity.rank,
    );
  }

  /// Convert to Firestore document (partial update for chaos fields)
  Map<String, dynamic> toChaosFields() {
    return {
      'totalChaosPoints': totalChaosPoints,
      'rank': rank,
    };
  }
}
