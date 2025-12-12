import 'package:equatable/equatable.dart';

/// Domain entity representing a generated humorous story
class StoryEntity extends Equatable {
  final String id;
  final String userId;
  final String text;
  final DateTime timestamp;

  const StoryEntity({
    required this.id,
    required this.userId,
    required this.text,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, userId, text, timestamp];
}
