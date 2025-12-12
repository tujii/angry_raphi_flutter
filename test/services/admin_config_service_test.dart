import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/services/admin_config_service.dart';

void main() {
  group('AdminInfo', () {
    test('should create AdminInfo with required properties', () {
      const adminInfo = AdminInfo(
        email: 'admin@example.com',
        displayName: 'Admin User',
        role: 'admin',
      );

      expect(adminInfo.email, 'admin@example.com');
      expect(adminInfo.displayName, 'Admin User');
      expect(adminInfo.role, 'admin');
    });

    test('should return true for isSuperAdmin when role is super_admin', () {
      const adminInfo = AdminInfo(
        email: 'admin@example.com',
        displayName: 'Super Admin',
        role: 'super_admin',
      );

      expect(adminInfo.isSuperAdmin, true);
    });

    test('should return false for isSuperAdmin when role is not super_admin', () {
      const adminInfo = AdminInfo(
        email: 'admin@example.com',
        displayName: 'Admin User',
        role: 'admin',
      );

      expect(adminInfo.isSuperAdmin, false);
    });
  });

  group('AdminConfigService', () {
    test('loadAdminConfig should return list of AdminInfo', () async {
      // act
      final admins = await AdminConfigService.loadAdminConfig();

      // assert
      expect(admins, isA<List<AdminInfo>>());
      expect(admins.isNotEmpty, true);
    });

    test('isAdmin should return true for predefined admin emails', () async {
      // This tests the fallback to predefined list
      const predefinedEmail = '17tujii@gmail.com';

      // act
      final result = await AdminConfigService.isAdmin(predefinedEmail);

      // assert
      expect(result, true);
    });

    test('isAdmin should return false for non-admin emails', () async {
      const nonAdminEmail = 'notadmin@example.com';

      // act
      final result = await AdminConfigService.isAdmin(nonAdminEmail);

      // assert
      expect(result, false);
    });

    test('getAdminDisplayName should return display name for admin email',
        () async {
      const email = '17tujii@gmail.com';

      // act
      final displayName = await AdminConfigService.getAdminDisplayName(email);

      // assert
      expect(displayName, isNotEmpty);
      expect(displayName, isA<String>());
    });

    test('getAdminDisplayName should return email prefix for unknown email',
        () async {
      const email = 'unknown@example.com';

      // act
      final displayName = await AdminConfigService.getAdminDisplayName(email);

      // assert
      expect(displayName, 'unknown');
    });

    test('getAdminEmails should return list of admin emails', () async {
      // act
      final emails = await AdminConfigService.getAdminEmails();

      // assert
      expect(emails, isA<List<String>>());
      expect(emails.isNotEmpty, true);
      expect(emails.every((email) => email.contains('@')), true);
    });

    test('getAdminEmails should include predefined admins', () async {
      // act
      final emails = await AdminConfigService.getAdminEmails();

      // assert
      expect(emails.contains('17tujii@gmail.com'), true);
      expect(emails.contains('uhlmannraphael@gmail.com'), true);
      expect(emails.contains('serenalenherr@gmail.com'), true);
    });
  });
}
