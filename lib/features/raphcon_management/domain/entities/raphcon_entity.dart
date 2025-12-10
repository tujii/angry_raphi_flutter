import 'package:equatable/equatable.dart';

import '../../../../core/enums/raphcon_type.dart';

class RaphconEntity extends Equatable {
  final String? id;
  final String userId;
  final String createdBy;
  final DateTime createdAt;
  final String? comment;
  final RaphconType type;
  final bool isActive;

  const RaphconEntity({
    this.id,
    required this.userId,
    required this.createdBy,
    required this.createdAt,
    this.comment,
    this.type = RaphconType.other, // Default to 'other' if not specified
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        createdBy,
        createdAt,
        comment,
        type,
        isActive,
      ];

  RaphconEntity copyWith({
    String? id,
    String? userId,
    String? createdBy,
    DateTime? createdAt,
    String? comment,
    RaphconType? type,
    bool? isActive,
  }) {
    return RaphconEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      comment: comment ?? this.comment,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
    );
  }
}
