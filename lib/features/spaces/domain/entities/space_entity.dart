import 'package:equatable/equatable.dart';

/// A space (tenant) that groups persons and raphcons.
///
/// Only members of a space can see its content.
class SpaceEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String createdBy;
  final DateTime createdAt;

  const SpaceEntity({
    required this.id,
    required this.name,
    this.description,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, description, createdBy, createdAt];
}
