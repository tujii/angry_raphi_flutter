/// User entity representing a user in the domain layer
/// This is the core business object following Clean Architecture principles
class User {
  final String id;
  final String initials; // Changed from name to initials (e.g., "M.M.")
  final String? avatarUrl;
  final int raphconCount;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.initials,
    this.avatarUrl,
    required this.raphconCount,
    required this.createdAt,
  });

  /// Get display name (backwards compatibility)
  String get name => initials;

  User copyWith({
    String? id,
    String? initials,
    String? avatarUrl,
    int? raphconCount,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      initials: initials ?? this.initials,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      raphconCount: raphconCount ?? this.raphconCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, initials: $initials, avatarUrl: $avatarUrl, raphconCount: $raphconCount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.initials == initials &&
        other.avatarUrl == avatarUrl &&
        other.raphconCount == raphconCount &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        initials.hashCode ^
        (avatarUrl?.hashCode ?? 0) ^
        raphconCount.hashCode ^
        createdAt.hashCode;
  }
}
