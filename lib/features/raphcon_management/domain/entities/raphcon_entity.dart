import 'package:equatable/equatable.dart';

class RaphconEntity extends Equatable {
  final String? id;
  final String userId;
  final String createdBy;
  final DateTime createdAt;
  final String? comment;

  const RaphconEntity({
    this.id,
    required this.userId,
    required this.createdBy,
    required this.createdAt,
    this.comment,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        createdBy,
        createdAt,
        comment,
      ];

  RaphconEntity copyWith({
    String? id,
    String? userId,
    String? createdBy,
    DateTime? createdAt,
    String? comment,
  }) {
    return RaphconEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      comment: comment ?? this.comment,
    );
  }
}
