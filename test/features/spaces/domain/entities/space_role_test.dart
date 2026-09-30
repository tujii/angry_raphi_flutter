import 'package:angry_raphi/features/spaces/domain/entities/space_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpaceRole', () {
    test('fromString parses stored values', () {
      for (final role in SpaceRole.values) {
        expect(SpaceRole.fromString(role.value), role);
      }
    });

    test('fromString falls back to viewer for unknown values', () {
      expect(SpaceRole.fromString(null), SpaceRole.viewer);
      expect(SpaceRole.fromString('superuser'), SpaceRole.viewer);
    });

    test('permissions are cumulative', () {
      expect(SpaceRole.viewer.canReport, isFalse);
      expect(SpaceRole.member.canReport, isTrue);
      expect(SpaceRole.member.canManageMembers, isFalse);
      expect(SpaceRole.admin.canManageMembers, isTrue);
      expect(SpaceRole.admin.canManagePersons, isTrue);
      expect(SpaceRole.admin.canDeleteSpace, isFalse);
      expect(SpaceRole.owner.canDeleteSpace, isTrue);
    });

    test('only owners can assign the owner role', () {
      expect(SpaceRole.owner.assignableRoles, contains(SpaceRole.owner));
      expect(SpaceRole.admin.assignableRoles, isNot(contains(SpaceRole.owner)));
      expect(SpaceRole.member.assignableRoles, isEmpty);
      expect(SpaceRole.viewer.assignableRoles, isEmpty);
    });

    test('admins cannot manage owners', () {
      expect(SpaceRole.admin.canManageMemberWithRole(SpaceRole.owner), isFalse);
      expect(SpaceRole.admin.canManageMemberWithRole(SpaceRole.admin), isTrue);
      expect(SpaceRole.owner.canManageMemberWithRole(SpaceRole.owner), isTrue);
      expect(
          SpaceRole.member.canManageMemberWithRole(SpaceRole.viewer), isFalse);
    });
  });
}
