/// Role of a member inside a space.
///
/// Permissions are cumulative: every role can do everything the roles
/// below it can do.
/// - [viewer]: can read persons and raphcons
/// - [member]: can additionally report raphcons and withdraw their own
/// - [admin]: can additionally manage persons, raphcons and members
/// - [owner]: can additionally delete the space and appoint owners
enum SpaceRole {
  viewer('viewer'),
  member('member'),
  admin('admin'),
  owner('owner');

  const SpaceRole(this.value);

  /// Value stored in Firestore
  final String value;

  /// Parses a stored role; unknown values fall back to [viewer] (least privilege).
  static SpaceRole fromString(String? value) {
    return SpaceRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => SpaceRole.viewer,
    );
  }

  bool get canReport => index >= SpaceRole.member.index;

  bool get canManagePersons => index >= SpaceRole.admin.index;

  bool get canManageRaphcons => index >= SpaceRole.admin.index;

  bool get canManageMembers => index >= SpaceRole.admin.index;

  bool get canDeleteSpace => this == SpaceRole.owner;

  /// Roles this role may hand out to others (invite or change to).
  List<SpaceRole> get assignableRoles {
    switch (this) {
      case SpaceRole.owner:
        return SpaceRole.values;
      case SpaceRole.admin:
        return const [SpaceRole.viewer, SpaceRole.member, SpaceRole.admin];
      case SpaceRole.member:
      case SpaceRole.viewer:
        return const [];
    }
  }

  /// Whether this role may change or remove a member holding [target].
  bool canManageMemberWithRole(SpaceRole target) {
    if (this == SpaceRole.owner) return true;
    return canManageMembers && target != SpaceRole.owner;
  }
}
