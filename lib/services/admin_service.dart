import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/admin/domain/repositories/admin_repository.dart';
import 'admin_config_service.dart';

/// Service for managing admin user privileges and initialization.
///
/// Handles admin user creation, status checking, and ensures proper
/// admin setup during application initialization. Works in conjunction
/// with Firebase Authentication and the admin repository.
@injectable
class AdminService {
  /// Repository for admin data operations
  final AdminRepository adminRepository;
  
  /// Firebase authentication instance
  final FirebaseAuth firebaseAuth;

  /// Creates an [AdminService] instance.
  ///
  /// Requires:
  /// - [adminRepository]: Repository for admin data operations
  /// - [firebaseAuth]: Firebase authentication instance
  AdminService({
    required this.adminRepository,
    required this.firebaseAuth,
  });

  /// Ensures an admin account exists for the specified email.
  ///
  /// Checks if the current authenticated user matches the provided email
  /// and creates an admin account if necessary. This is typically called
  /// during application initialization.
  ///
  /// Parameters:
  /// - [email]: The email address of the admin to ensure exists
  ///
  /// Note: Failures are silently handled to prevent app startup issues.
  ///
  /// Example:
  /// ```dart
  /// await adminService.ensureAdminExists('admin@example.com');
  /// ```
  Future<void> ensureAdminExists(String email) async {
    try {
      // Check current user for admin setup
      final currentUser = firebaseAuth.currentUser;

      if (currentUser != null && currentUser.email == email) {
        // Current user is the admin we want to create
        await _createAdminIfNotExists(
          currentUser.uid,
          currentUser.email!,
          currentUser.displayName ?? email.split('@')[0],
        );
      }
    } catch (e) {
      // Error checking admin - silent in production
    }
  }

  /// Creates an admin account if one doesn't already exist.
  ///
  /// Internal method that checks admin status and creates the admin
  /// account if needed. Failures are silently handled.
  ///
  /// Parameters:
  /// - [userId]: The user ID from Firebase Auth
  /// - [email]: The admin's email address
  /// - [displayName]: The admin's display name
  Future<void> _createAdminIfNotExists(
    String userId,
    String email,
    String displayName,
  ) async {
    final adminCheckResult = await adminRepository.checkAdminStatus(email);

    adminCheckResult.fold(
      (failure) => {}, // Error checking admin status - silent in production
      (isAdmin) async {
        if (!isAdmin) {
          final addAdminResult = await adminRepository.addAdmin(
            userId,
            email,
            displayName,
          );

          addAdminResult.fold(
            (failure) => {}, // Error adding admin - silent in production
            (_) => {}, // Admin added successfully
          );
        } else {
          // Admin already exists
        }
      },
    );
  }

  /// Checks if the current user matches the target email and creates admin if so.
  ///
  /// Verifies that the currently authenticated user's email matches the
  /// target admin email, then creates the admin account if necessary.
  ///
  /// Parameters:
  /// - [targetEmail]: The email address to check against the current user
  ///
  /// Example:
  /// ```dart
  /// await adminService.checkAndCreateCurrentUserAsAdmin('admin@example.com');
  /// ```
  Future<void> checkAndCreateCurrentUserAsAdmin(String targetEmail) async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser != null && currentUser.email == targetEmail) {
      await _createAdminIfNotExists(
        currentUser.uid,
        currentUser.email!,
        currentUser.displayName ?? targetEmail.split('@')[0],
      );
    }
  }

  /// Checks if the current user should be an admin after login.
  ///
  /// Performs a two-step check:
  /// 1. Verifies if the user is configured as admin in the CSV config
  /// 2. Checks if the user already has admin status in the database
  ///
  /// If the user is a configured admin but not in the database,
  /// this method will create the admin account.
  ///
  /// Returns `true` if the user is or becomes an admin, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final isAdmin = await adminService.checkAndUpdateAdminStatus();
  /// if (isAdmin) {
  ///   // Show admin features
  /// }
  /// ```
  Future<bool> checkAndUpdateAdminStatus() async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser?.email != null) {
      // Check if user is admin from CSV configuration
      final isConfiguredAdmin =
          await AdminConfigService.isAdmin(currentUser!.email!);

      if (isConfiguredAdmin) {
        await checkAndCreateCurrentUserAsAdmin(currentUser.email!);
        return true;
      }
    }

    // Check if user is already admin in database
    if (currentUser != null) {
      final adminCheckResult =
          await adminRepository.checkAdminStatus(currentUser.email ?? '');
      return adminCheckResult.fold((failure) => false, (isAdmin) => isAdmin);
    }

    return false;
  }
}
