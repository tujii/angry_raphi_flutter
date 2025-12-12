import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/story_entity.dart';

/// Data model for story with Firestore serialization
class StoryModel extends StoryEntity {
  const StoryModel({
    required super.id,
    required super.userId,
    required super.text,
    required super.timestamp,
  });

  /// Create model from Firestore document
  factory StoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return StoryModel(
      id: snapshot.id,
      userId: data['userId'] as String,
      text: data['text'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Create model from entity
  factory StoryModel.fromEntity(StoryEntity entity) {
    return StoryModel(
      id: entity.id,
      userId: entity.userId,
      text: entity.text,
      timestamp: entity.timestamp,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
