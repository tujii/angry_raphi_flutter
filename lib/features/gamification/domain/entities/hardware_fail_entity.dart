import 'package:equatable/equatable.dart';
import '../../../../core/enums/raphcon_type.dart';

/// Domain entity representing a hardware fail event
class HardwareFailEntity extends Equatable {
  final String id;
  final String userId;
  final RaphconType type;
  final DateTime timestamp;

  const HardwareFailEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, userId, type, timestamp];
}
