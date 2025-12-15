import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/raphcon_management/domain/entities/raphcon_entity.dart';
import 'package:angry_raphi/core/enums/raphcon_type.dart';

void main() {
  group('RaphconEntity', () {
    final testDate = DateTime(2024, 1);

    test('creates raphcon with required fields', () {
      final raphcon = RaphconEntity(
        userId: 'user123',
        createdBy: 'admin456',
        createdAt: testDate,
      );

      expect(raphcon.id, isNull);
      expect(raphcon.userId, equals('user123'));
      expect(raphcon.createdBy, equals('admin456'));
      expect(raphcon.createdAt, equals(testDate));
      expect(raphcon.comment, isNull);
      expect(raphcon.type, equals(RaphconType.other));
      expect(raphcon.isActive, isTrue);
    });

    test('creates raphcon with all fields', () {
      final raphcon = RaphconEntity(
        id: 'raphcon789',
        userId: 'user123',
        createdBy: 'admin456',
        createdAt: testDate,
        comment: 'Test comment',
        type: RaphconType.keyboard,
        isActive: false,
      );

      expect(raphcon.id, equals('raphcon789'));
      expect(raphcon.userId, equals('user123'));
      expect(raphcon.createdBy, equals('admin456'));
      expect(raphcon.createdAt, equals(testDate));
      expect(raphcon.comment, equals('Test comment'));
      expect(raphcon.type, equals(RaphconType.keyboard));
      expect(raphcon.isActive, isFalse);
    });

    test('copyWith creates new raphcon with updated fields', () {
      final raphcon = RaphconEntity(
        userId: 'user123',
        createdBy: 'admin456',
        createdAt: testDate,
      );

      final updated = raphcon.copyWith(
        id: 'new_id',
        comment: 'New comment',
        type: RaphconType.mouse,
        isActive: false,
      );

      expect(updated.id, equals('new_id'));
      expect(updated.userId, equals('user123'));
      expect(updated.createdBy, equals('admin456'));
      expect(updated.comment, equals('New comment'));
      expect(updated.type, equals(RaphconType.mouse));
      expect(updated.isActive, isFalse);
    });

    test('copyWith with no parameters returns same values', () {
      final raphcon = RaphconEntity(
        id: 'id1',
        userId: 'user123',
        createdBy: 'admin456',
        createdAt: testDate,
        comment: 'Comment',
        type: RaphconType.network,
      );

      final copy = raphcon.copyWith();

      expect(copy.id, equals(raphcon.id));
      expect(copy.userId, equals(raphcon.userId));
      expect(copy.createdBy, equals(raphcon.createdBy));
      expect(copy.comment, equals(raphcon.comment));
      expect(copy.type, equals(raphcon.type));
    });

    test('props returns correct list', () {
      final raphcon = RaphconEntity(
        id: 'id1',
        userId: 'user123',
        createdBy: 'admin456',
        createdAt: testDate,
        comment: 'Comment',
        type: RaphconType.software,
      );

      expect(
        raphcon.props,
        equals([
          'id1',
          'user123',
          'admin456',
          testDate,
          'Comment',
          RaphconType.software,
          true,
        ]),
      );
    });

    test('equality works correctly', () {
      final raphcon1 = RaphconEntity(
        id: 'id1',
        userId: 'user123',
        createdBy: 'admin456',
        createdAt: testDate,
      );

      final raphcon2 = RaphconEntity(
        id: 'id1',
        userId: 'user123',
        createdBy: 'admin456',
        createdAt: testDate,
      );

      expect(raphcon1, equals(raphcon2));
    });

    test('equality returns false for different raphcons', () {
      final raphcon1 = RaphconEntity(
        id: 'id1',
        userId: 'user123',
        createdBy: 'admin456',
        createdAt: testDate,
      );

      final raphcon2 = RaphconEntity(
        id: 'id2',
        userId: 'user456',
        createdBy: 'admin789',
        createdAt: testDate,
      );

      expect(raphcon1, isNot(equals(raphcon2)));
    });
  });
}
