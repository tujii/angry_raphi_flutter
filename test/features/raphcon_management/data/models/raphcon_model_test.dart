import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/raphcon_management/data/models/raphcon_model.dart';
import 'package:angry_raphi/features/raphcon_management/domain/entities/raphcon_entity.dart';
import 'package:angry_raphi/core/enums/raphcon_type.dart';

void main() {
  group('RaphconModel', () {
    const testDate = DateTime(2024, 1, 1);

    test('fromMap creates model from map', () {
      final map = {
        'userId': 'user123',
        'createdBy': 'admin456',
        'createdAt': testDate,
        'comment': 'Test comment',
        'type': 'keyboard',
        'isActive': true,
      };

      final model = RaphconModel.fromMap(map, 'raphcon789');

      expect(model.id, equals('raphcon789'));
      expect(model.userId, equals('user123'));
      expect(model.createdBy, equals('admin456'));
      expect(model.createdAt, equals(testDate));
      expect(model.comment, equals('Test comment'));
      expect(model.type, equals(RaphconType.keyboard));
      expect(model.isActive, isTrue);
    });

    test('fromMap handles missing optional fields', () {
      final map = {
        'userId': 'user123',
        'createdBy': 'admin456',
        'createdAt': testDate,
      };

      final model = RaphconModel.fromMap(map, 'raphcon789');

      expect(model.id, equals('raphcon789'));
      expect(model.userId, equals('user123'));
      expect(model.createdBy, equals('admin456'));
      expect(model.comment, isNull);
      expect(model.type, equals(RaphconType.other));
      expect(model.isActive, isTrue);
    });

    test('fromMap handles invalid type string', () {
      final map = {
        'userId': 'user123',
        'createdBy': 'admin456',
        'createdAt': testDate,
        'type': 'invalid_type',
      };

      final model = RaphconModel.fromMap(map, 'raphcon789');

      expect(model.type, equals(RaphconType.other));
    });

    test('toMap converts model to map', () {
      final model = RaphconModel(
        id: 'raphcon789',
        userId: 'user123',
        createdBy: 'admin456',
        createdAt: testDate,
        comment: 'Test comment',
        type: RaphconType.mouse,
        isActive: true,
      );

      final map = model.toMap();

      expect(map['userId'], equals('user123'));
      expect(map['createdBy'], equals('admin456'));
      expect(map['createdAt'], equals(testDate));
      expect(map['comment'], equals('Test comment'));
      expect(map['type'], equals('mouse'));
      expect(map['isActive'], isTrue);
    });

    test('toMap excludes id field', () {
      final model = RaphconModel(
        id: 'raphcon789',
        userId: 'user123',
        createdBy: 'admin456',
        createdAt: testDate,
      );

      final map = model.toMap();

      expect(map.containsKey('id'), isFalse);
    });

    test('fromEntity creates model from entity', () {
      final entity = RaphconEntity(
        id: 'raphcon789',
        userId: 'user123',
        createdBy: 'admin456',
        createdAt: testDate,
        comment: 'Test comment',
        type: RaphconType.network,
        isActive: false,
      );

      final model = RaphconModel.fromEntity(entity);

      expect(model.id, equals('raphcon789'));
      expect(model.userId, equals('user123'));
      expect(model.createdBy, equals('admin456'));
      expect(model.createdAt, equals(testDate));
      expect(model.comment, equals('Test comment'));
      expect(model.type, equals(RaphconType.network));
      expect(model.isActive, isFalse);
    });

    test('model extends entity', () {
      final model = RaphconModel(
        id: 'raphcon789',
        userId: 'user123',
        createdBy: 'admin456',
        createdAt: testDate,
      );

      expect(model, isA<RaphconEntity>());
    });
  });
}
