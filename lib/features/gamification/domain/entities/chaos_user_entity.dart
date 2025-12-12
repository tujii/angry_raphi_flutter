import 'package:equatable/equatable.dart';

/// Domain entity representing user chaos points and rank
class ChaosUserEntity extends Equatable {
  final String userId;
  final String name;
  final int totalChaosPoints;
  final String rank;

  const ChaosUserEntity({
    required this.userId,
    required this.name,
    required this.totalChaosPoints,
    required this.rank,
  });

  /// Calculate rank based on chaos points
  static String calculateRank(int points) {
    if (points >= 100) return 'Chaos Master';
    if (points >= 50) return 'Chaos Expert';
    if (points >= 20) return 'Chaos Enthusiast';
    if (points >= 10) return 'Chaos Novice';
    return 'Chaos Beginner';
  }

  @override
  List<Object?> get props => [userId, name, totalChaosPoints, rank];
}
