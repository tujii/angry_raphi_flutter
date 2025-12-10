import 'package:flutter/services.dart';

/// Data class for admin information
class AdminInfo {
  final String email;
  final String displayName;
  final String role;

  const AdminInfo({
    required this.email,
    required this.displayName,
    required this.role,
  });

  bool get isSuperAdmin => role == 'super_admin';
}

/// Service to manage admin configuration from CSV file
class AdminConfigService {
  static const String _csvPath = 'assets/data/admins.csv';

  /// Admin data structure
  static const List<String> _predefinedAdmins = [
    '17tujii@gmail.com',
    'uhlmannraphael@gmail.com',
    'serenalenherr@gmail.com',
  ];

  /// Load admin configuration from CSV file
  static Future<List<AdminInfo>> loadAdminConfig() async {
    try {
      final csvContent = await rootBundle.loadString(_csvPath);
      final lines = csvContent.split('\n');

      // Skip header row and process data
      final adminList = <AdminInfo>[];

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final parts = line.split(',');
        if (parts.length >= 3) {
          adminList.add(AdminInfo(
            email: parts[0].trim(),
            displayName: parts[1].trim(),
            role: parts[2].trim(),
          ));
        }
      }

      return adminList;
    } catch (e) {
      // Fallback to predefined list if CSV loading fails
      return _predefinedAdmins
          .map((email) => AdminInfo(
                email: email,
                displayName: email.split('@')[0],
                role: 'admin',
              ))
          .toList();
    }
  }

  /// Check if an email is an admin
  static Future<bool> isAdmin(String email) async {
    final admins = await loadAdminConfig();
    return admins.any((admin) => admin.email == email);
  }

  /// Get admin display name
  static Future<String> getAdminDisplayName(String email) async {
    final admins = await loadAdminConfig();
    final admin = admins.firstWhere(
      (admin) => admin.email == email,
      orElse: () => AdminInfo(
        email: email,
        displayName: email.split('@')[0],
        role: 'admin',
      ),
    );
    return admin.displayName;
  }

  /// Get all admin emails
  static Future<List<String>> getAdminEmails() async {
    final admins = await loadAdminConfig();
    return admins.map((admin) => admin.email).toList();
  }
}
