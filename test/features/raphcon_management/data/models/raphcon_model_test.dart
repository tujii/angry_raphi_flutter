import 'package:angry_raphi/core/enums/raphcon_type.dart';
import 'package:angry_raphi/features/raphcon_management/data/models/raphcon_model.dart';
import 'package:angry_raphi/features/raphcon_management/domain/entities/raphcon_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RaphconModel', () {
    final testDate = DateTime(2024);

    test('fromMap creates model from map', () {
      final map = {
        'userId': 'user123',
        'createdBy': 'admin456',
        'createdAt': testDate,
        'comment': 'Test comment',
        'type': 'headset',
        'isActive': true,
      };

      final model = RaphconModel.fromMap(map, 'raphcon789');

      expect(model.id, equals('raphcon789'));
      expect(model.userId, equals('user123'));
      expect(model.createdBy, equals('admin456'));
      expect(model.createdAt, equals(testDate));
      expect(model.comment, equals('Test comment'));
      expect(model.type, equals(RaphconType.headset));
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
      expect(model.type, equals(RaphconType.otherPeripherals));
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

      expect(model.type, equals(RaphconType.otherPeripherals));
    });

    test('fromMap maps old types to new types for backward compatibility', () {
      // Test old peripheral types map to otherPeripherals
      final mouseMap = {
        'userId': 'user123',
        'createdBy': 'admin456',
        'createdAt': testDate,
        'type': 'mouse',
      };
      expect(RaphconModel.fromMap(mouseMap, 'id1').type, equals(RaphconType.otherPeripherals));

      final keyboardMap = {
        'userId': 'user123',
        'createdBy': 'admin456',
        'createdAt': testDate,
        'type': 'keyboard',
      };
      expect(RaphconModel.fromMap(keyboardMap, 'id2').type, equals(RaphconType.otherPeripherals));

      // Test microphone maps to headset
      final micMap = {
        'userId': 'user123',
        'createdBy': 'admin456',
        'createdAt': testDate,
        'type': 'microphone',
      };
      expect(RaphconModel.fromMap(micMap, 'id3').type, equals(RaphconType.headset));
    });

    test('toMap converts model to map', () {
      final model = RaphconModel(
        id: 'raphcon789',
        userId: 'user123',
        createdBy: 'admin456',
        createdAt: testDate,
        comment: 'Test comment',
        type: RaphconType.webcam,
      );

      final map = model.toMap();

      expect(map['userId'], equals('user123'));
      expect(map['createdBy'], equals('admin456'));
      expect(map['createdAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate(), equals(testDate));
      expect(map['comment'], equals('Test comment'));
      expect(map['type'], equals('webcam'));
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
        type: RaphconType.mouseHighlighter,
        isActive: false,
      );

      final model = RaphconModel.fromEntity(entity);

      expect(model.id, equals('raphcon789'));
      expect(model.userId, equals('user123'));
      expect(model.createdBy, equals('admin456'));
      expect(model.createdAt, equals(testDate));
      expect(model.comment, equals('Test comment'));
      expect(model.type, equals(RaphconType.mouseHighlighter));
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
