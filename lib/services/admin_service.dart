import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/admin/domain/repositories/admin_repository.dart';

@injectable
class AdminService {
  final AdminRepository adminRepository;
  final FirebaseAuth firebaseAuth;

  AdminService({
    required this.adminRepository,
    required this.firebaseAuth,
  });

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

  Future<void> _createAdminIfNotExists(
    String userId,
    String email,
    String displayName,
  ) async {
    final adminCheckResult = await adminRepository.checkAdminStatus(userId);

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

  /// Checks if the current user should be an admin after login
  Future<bool> checkAndUpdateAdminStatus() async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser?.email == '17tujii@gmail.com' ||
        currentUser?.email == 'uhlmannraphael@gmail.com') {
      await checkAndCreateCurrentUserAsAdmin('17tujii@gmail.com');
      await checkAndCreateCurrentUserAsAdmin('uhlmannraphael@gmail.com');
      return true;
    }

    // Check if user is already admin
    if (currentUser != null) {
      final adminCheckResult =
          await adminRepository.checkAdminStatus(currentUser.uid);
      return adminCheckResult.fold((failure) => false, (isAdmin) => isAdmin);
    }

    return false;
  }
}
