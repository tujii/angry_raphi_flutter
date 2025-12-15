import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/admin/domain/entities/admin_entity.dart';

void main() {
  group('AdminEntity', () {
    const testDate = DateTime(2024, 1, 1);

    test('creates admin entity with all fields', () {
      final admin = AdminEntity(
        id: 'admin123',
        email: 'admin@example.com',
        displayName: 'Admin User',
        createdAt: testDate,
        isActive: true,
      );

      expect(admin.id, equals('admin123'));
      expect(admin.email, equals('admin@example.com'));
      expect(admin.displayName, equals('Admin User'));
      expect(admin.createdAt, equals(testDate));
      expect(admin.isActive, isTrue);
    });

    test('props returns correct list', () {
      final admin = AdminEntity(
        id: 'admin123',
        email: 'admin@example.com',
        displayName: 'Admin User',
        createdAt: testDate,
        isActive: true,
      );

      expect(
        admin.props,
        equals([
          'admin123',
          'admin@example.com',
          'Admin User',
          testDate,
          true,
        ]),
      );
    });

    test('equality works correctly', () {
      final admin1 = AdminEntity(
        id: 'admin123',
        email: 'admin@example.com',
        displayName: 'Admin User',
        createdAt: testDate,
        isActive: true,
      );

      final admin2 = AdminEntity(
        id: 'admin123',
        email: 'admin@example.com',
        displayName: 'Admin User',
        createdAt: testDate,
        isActive: true,
      );

      expect(admin1, equals(admin2));
    });

    test('equality returns false for different admins', () {
      final admin1 = AdminEntity(
        id: 'admin123',
        email: 'admin@example.com',
        displayName: 'Admin User',
        createdAt: testDate,
        isActive: true,
      );

      final admin2 = AdminEntity(
        id: 'admin456',
        email: 'other@example.com',
        displayName: 'Other Admin',
        createdAt: testDate,
        isActive: false,
      );

      expect(admin1, isNot(equals(admin2)));
    });

    test('different active status changes equality', () {
      final admin1 = AdminEntity(
        id: 'admin123',
        email: 'admin@example.com',
        displayName: 'Admin User',
        createdAt: testDate,
        isActive: true,
      );

      final admin2 = AdminEntity(
        id: 'admin123',
        email: 'admin@example.com',
        displayName: 'Admin User',
        createdAt: testDate,
        isActive: false,
      );

      expect(admin1, isNot(equals(admin2)));
    });
  });
}
