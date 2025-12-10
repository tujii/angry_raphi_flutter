import 'package:equatable/equatable.dart';

class PersonEntity extends Equatable {
  final String? id;
  final String name;
  final String? description;
  final String? profileImageUrl;
  final int raphconCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PersonEntity({
    this.id,
    required this.name,
    this.description,
    this.profileImageUrl,
    required this.raphconCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        profileImageUrl,
        raphconCount,
        createdAt,
        updatedAt,
      ];

  PersonEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? profileImageUrl,
    int? raphconCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      raphconCount: raphconCount ?? this.raphconCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
