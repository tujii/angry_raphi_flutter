/// User entity representing a user in the domain layer
/// This is the core business object following Clean Architecture principles
class User {
  final String id;
  final String name;
  final String? avatarUrl;
  final int raphconCount;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.raphconCount,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    int? raphconCount,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      raphconCount: raphconCount ?? this.raphconCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, avatarUrl: $avatarUrl, raphconCount: $raphconCount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.avatarUrl == avatarUrl &&
        other.raphconCount == raphconCount &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        (avatarUrl?.hashCode ?? 0) ^
        raphconCount.hashCode ^
        createdAt.hashCode;
  }
}
