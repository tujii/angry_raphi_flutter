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
      // This tests the fallback to predefined list by checking if any
      // admin emails exist (without hardcoding specific real emails)
      final adminEmails = await AdminConfigService.getAdminEmails();
      
      // Use the first admin email from the config for testing
      if (adminEmails.isNotEmpty) {
        final firstAdminEmail = adminEmails.first;
        
        // act
        final result = await AdminConfigService.isAdmin(firstAdminEmail);

        // assert
        expect(result, true);
      }
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
      // Get an actual admin email from the config
      final emails = await AdminConfigService.getAdminEmails();
      
      if (emails.isNotEmpty) {
        final email = emails.first;

        // act
        final displayName = await AdminConfigService.getAdminDisplayName(email);

        // assert
        expect(displayName, isNotEmpty);
        expect(displayName, isA<String>());
      }
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
      // Verify all emails have valid format (contain @)
      expect(emails.every((email) => email.contains('@')), true);
      // Verify all emails are properly formatted with a domain
      expect(
        emails.every((email) => email.split('@').length == 2),
        true,
      );
    });

    test('getAdminEmails should include predefined admins', () async {
      // act
      final emails = await AdminConfigService.getAdminEmails();

      // assert - verify the list contains at least some admins
      // without hardcoding specific real email addresses
      expect(emails.length, greaterThanOrEqualTo(3));
      
      // Verify all returned emails are valid format
      for (final email in emails) {
        expect(email, contains('@'));
        expect(email, contains('.'));
      }
    });
  });
}
