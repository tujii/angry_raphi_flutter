import 'package:angry_raphi/features/spaces/data/models/space_invitation_model.dart';
import 'package:angry_raphi/features/spaces/data/models/space_member_model.dart';
import 'package:angry_raphi/features/spaces/data/models/space_model.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_invitation_entity.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_role.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock Timestamp class for testing
class MockTimestamp {
  final DateTime _dateTime;
  MockTimestamp(this._dateTime);
  DateTime toDate() => _dateTime;
}

void main() {
  final testDate = DateTime(2024, 5, 6);

  group('SpaceModel', () {
    test('fromMap reads all fields', () {
      final model = SpaceModel.fromMap({
        'name': 'Team',
        'description': 'Our team',
        'createdBy': 'uid1',
        'createdAt': MockTimestamp(testDate),
      }, 'space1');

      expect(model.id, 'space1');
      expect(model.name, 'Team');
      expect(model.description, 'Our team');
      expect(model.createdBy, 'uid1');
      expect(model.createdAt, testDate);
    });

    test('toMap omits id and createdAt', () {
      final map = SpaceModel(
        id: 'space1',
        name: 'Team',
        createdBy: 'uid1',
        createdAt: testDate,
      ).toMap();

      expect(map, {'name': 'Team', 'description': null, 'createdBy': 'uid1'});
    });
  });

  group('SpaceMemberModel', () {
    test('round-trips through map', () {
      final model = SpaceMemberModel(
        uid: 'uid1',
        spaceId: 'space1',
        role: SpaceRole.admin,
        displayName: 'Max',
        email: 'max@example.com',
        joinedAt: testDate,
      );
      final map = model.toMap();

      expect(map['uid'], 'uid1');
      expect(map['spaceId'], 'space1');
      expect(map['role'], 'admin');

      final parsed =
          SpaceMemberModel.fromMap({...map, 'joinedAt': testDate}, 'uid1');
      expect(parsed, model);
    });

    test('unknown role becomes viewer', () {
      final model = SpaceMemberModel.fromMap(const {'role': 'god'}, 'uid1');
      expect(model.role, SpaceRole.viewer);
    });
  });

  group('SpaceInvitationModel', () {
    test('round-trips through map', () {
      final model = SpaceInvitationModel(
        id: 'inv1',
        spaceId: 'space1',
        spaceName: 'Team',
        email: 'a@b.ch',
        role: SpaceRole.member,
        invitedBy: 'uid1',
        createdAt: testDate,
      );
      final map = model.toMap();

      expect(map['status'], 'pending');
      final parsed = SpaceInvitationModel.fromMap(
          {...map, 'createdAt': MockTimestamp(testDate)}, 'inv1');
      expect(parsed, model);
    });

    test('parses status', () {
      final model =
          SpaceInvitationModel.fromMap(const {'status': 'declined'}, 'inv1');
      expect(model.status, InvitationStatus.declined);
    });
  });
}
