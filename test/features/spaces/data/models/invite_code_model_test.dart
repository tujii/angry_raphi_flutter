import 'package:angry_raphi/features/spaces/data/models/invite_code_model.dart';
import 'package:angry_raphi/features/spaces/domain/entities/space_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InviteCodeModel', () {
    test('round-trips through map', () {
      final model = InviteCodeModel(
        code: 'code1',
        spaceId: 'space1',
        spaceName: 'Team',
        role: SpaceRole.admin,
        createdBy: 'uid1',
        createdAt: DateTime(2024),
        expiresAt: DateTime(2024, 2),
      );
      final map = model.toMap();

      expect(map['role'], 'admin');
      expect(map['active'], isTrue);
      expect(map.containsKey('createdAt'), isFalse);

      final parsed = InviteCodeModel.fromMap(
          {...map, 'createdAt': DateTime(2024)}, 'code1');
      expect(parsed, model);
    });

    test('missing expiry means never expires, missing active means inactive',
        () {
      final model = InviteCodeModel.fromMap(const {'role': 'member'}, 'c');
      expect(model.expiresAt, isNull);
      expect(model.active, isFalse);
    });
  });
}
