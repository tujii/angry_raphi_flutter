import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/admin/data/models/admin_model.dart';
import 'package:angry_raphi/features/admin/domain/entities/admin_entity.dart';

// Mock Timestamp class for testing
class MockTimestamp {
  final DateTime _dateTime;
  MockTimestamp(this._dateTime);
  DateTime toDate() => _dateTime;
}

void main() {
  group('AdminModel', () {
    final testDate = DateTime(2024, 1, 1);

    test('creates admin model with all fields', () {
      final model = AdminModel(
        id: 'admin123',
        email: 'admin@example.com',
        displayName: 'Admin User',
        createdAt: testDate,
        isActive: true,
      );

      expect(model.id, equals('admin123'));
      expect(model.email, equals('admin@example.com'));
      expect(model.displayName, equals('Admin User'));
      expect(model.createdAt, equals(testDate));
      expect(model.isActive, isTrue);
    });

    test('fromMap creates model from map', () {
      final map = {
        'email': 'admin@example.com',
        'displayName': 'Admin User',
        'createdAt': MockTimestamp(testDate),
        'isActive': true,
      };

      final model = AdminModel.fromMap(map, 'admin123');

      expect(model.id, equals('admin123'));
      expect(model.email, equals('admin@example.com'));
      expect(model.displayName, equals('Admin User'));
      expect(model.createdAt, equals(testDate));
      expect(model.isActive, isTrue);
    });

    test('fromMap handles missing isActive field', () {
      final map = {
        'email': 'admin@example.com',
        'displayName': 'Admin User',
        'createdAt': MockTimestamp(testDate),
      };

      final model = AdminModel.fromMap(map, 'admin123');

      expect(model.isActive, isTrue);
    });

    test('toMap converts model to map', () {
      final model = AdminModel(
        id: 'admin123',
        email: 'admin@example.com',
        displayName: 'Admin User',
        createdAt: testDate,
        isActive: true,
      );

      final map = model.toMap();

      expect(map['email'], equals('admin@example.com'));
      expect(map['displayName'], equals('Admin User'));
      expect(map['createdAt'], equals(testDate));
      expect(map['isActive'], isTrue);
    });

    test('toMap excludes id field', () {
      final model = AdminModel(
        id: 'admin123',
        email: 'admin@example.com',
        displayName: 'Admin User',
        createdAt: testDate,
        isActive: true,
      );

      final map = model.toMap();

      expect(map.containsKey('id'), isFalse);
    });

    test('fromEntity creates model from entity', () {
      final entity = AdminEntity(
        id: 'admin123',
        email: 'admin@example.com',
        displayName: 'Admin User',
        createdAt: testDate,
        isActive: false,
      );

      final model = AdminModel.fromEntity(entity);

      expect(model.id, equals('admin123'));
      expect(model.email, equals('admin@example.com'));
      expect(model.displayName, equals('Admin User'));
      expect(model.createdAt, equals(testDate));
      expect(model.isActive, isFalse);
    });

    test('model extends entity', () {
      final model = AdminModel(
        id: 'admin123',
        email: 'admin@example.com',
        displayName: 'Admin User',
        createdAt: testDate,
        isActive: true,
      );

      expect(model, isA<AdminEntity>());
    });
  });
}
