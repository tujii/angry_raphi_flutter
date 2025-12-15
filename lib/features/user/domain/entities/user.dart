/// User entity representing a user in the domain layer.
///
/// This is the core business object following Clean Architecture principles.
/// Represents a user in the AngryRaphi system who can create and receive raphcons.
///
/// A User consists of:
/// - [id]: Unique identifier for the user
/// - [initials]: User's initials (e.g., "M.M.") for display
/// - [avatarUrl]: Optional URL to the user's avatar image
/// - [raphconCount]: Total number of raphcons created by the user
/// - [createdAt]: When the user account was created
/// - [lastRaphconAt]: When the user last created a raphcon
/// - [isActive]: Whether the user account is currently active
class User {
  /// Unique identifier for the user
  final String id;
  
  /// User's initials (e.g., "M.M.") used for display
  final String initials;
  
  /// Optional URL to the user's avatar image
  final String? avatarUrl;
  
  /// Total number of raphcons created by this user
  final int raphconCount;
  
  /// Timestamp when the user account was created
  final DateTime createdAt;
  
  /// Timestamp when the user last created a raphcon
  final DateTime? lastRaphconAt;
  
  /// Whether the user account is currently active
  final bool isActive;

  /// Creates a [User] instance.
  ///
  /// All fields except [avatarUrl], [lastRaphconAt], and [isActive] are required.
  /// [isActive] defaults to `true` if not provided.
  const User({
    required this.id,
    required this.initials,
    this.avatarUrl,
    required this.raphconCount,
    required this.createdAt,
    this.lastRaphconAt,
    this.isActive = true,
  });

  /// Gets the display name (backwards compatibility).
  ///
  /// Returns the user's initials as the display name.
  String get name => initials;

  /// Creates a copy of this User with the specified fields replaced.
  ///
  /// Returns a new [User] instance with the same values as this instance,
  /// except for any fields explicitly provided in the parameters.
  ///
  /// Example:
  /// ```dart
  /// final updatedUser = user.copyWith(raphconCount: 5);
  /// ```
  User copyWith({
    String? id,
    String? initials,
    String? avatarUrl,
    int? raphconCount,
    DateTime? createdAt,
    DateTime? lastRaphconAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      initials: initials ?? this.initials,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      raphconCount: raphconCount ?? this.raphconCount,
      createdAt: createdAt ?? this.createdAt,
      lastRaphconAt: lastRaphconAt ?? this.lastRaphconAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, initials: $initials, avatarUrl: $avatarUrl, raphconCount: $raphconCount, createdAt: $createdAt, lastRaphconAt: $lastRaphconAt, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.initials == initials &&
        other.avatarUrl == avatarUrl &&
        other.raphconCount == raphconCount &&
        other.createdAt == createdAt &&
        other.lastRaphconAt == lastRaphconAt &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        initials.hashCode ^
        (avatarUrl?.hashCode ?? 0) ^
        raphconCount.hashCode ^
        createdAt.hashCode ^
        (lastRaphconAt?.hashCode ?? 0) ^
        isActive.hashCode;
  }
}
