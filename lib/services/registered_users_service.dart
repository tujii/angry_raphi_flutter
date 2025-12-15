import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';

/// Service for managing registered users in Firestore
/// This tracks all users who have successfully authenticated with the app
@injectable
class RegisteredUsersService {
  final FirebaseFirestore _firestore;

  RegisteredUsersService(this._firestore);

  /// Save or update a user in the registeredUsers collection
  /// Called when a user successfully signs in
  Future<void> saveRegisteredUser(User firebaseUser) async {
    try {
      final userDoc =
          _firestore.collection('registeredUsers').doc(firebaseUser.uid);

      final userData = {
        'uid': firebaseUser.uid,
        'email': firebaseUser.email ?? '',
        'displayName': firebaseUser.displayName ??
            firebaseUser.email?.split('@')[0] ??
            'Unknown User',
        'photoURL': firebaseUser.photoURL,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Check if user document already exists
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        // Update existing user with new login timestamp
        await userDoc.update({
          'lastLoginAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          // Update display name and photo if they changed
          'displayName': userData['displayName'],
          'photoURL': userData['photoURL'],
        });
      } else {
        // Create new user document
        userData['createdAt'] = FieldValue.serverTimestamp();
        await userDoc.set(userData);
      }
    } catch (e) {
      // Don't throw - we don't want auth to fail if user saving fails
      debugPrint('Failed to save registered user for ${firebaseUser.uid}: $e');
      if (kDebugMode) {
        print('Firestore error details: $e');
      }
    }
  }

  /// Get all registered users
  Future<List<Map<String, dynamic>>> getRegisteredUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('registeredUsers')
          .orderBy('lastLoginAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'uid': data['uid'] ?? doc.id,
          'email': data['email'] ?? '',
          'displayName': data['displayName'] ?? '',
          'photoURL': data['photoURL'],
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          'lastLoginAt': (data['lastLoginAt'] as Timestamp?)?.toDate(),
          'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
        };
      }).toList();
    } catch (e) {
      debugPrint('Failed to get registered users: $e');
      return [];
    }
  }

  /// Get a specific registered user by UID
  Future<Map<String, dynamic>?> getRegisteredUser(String uid) async {
    try {
      final docSnapshot =
          await _firestore.collection('registeredUsers').doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        return {
          'id': docSnapshot.id,
          'uid': data['uid'] ?? docSnapshot.id,
          'email': data['email'] ?? '',
          'displayName': data['displayName'] ?? '',
          'photoURL': data['photoURL'],
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          'lastLoginAt': (data['lastLoginAt'] as Timestamp?)?.toDate(),
          'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
        };
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get registered user: $e');
      return null;
    }
  }

  /// Check if a user is registered
  Future<bool> isUserRegistered(String uid) async {
    try {
      final docSnapshot =
          await _firestore.collection('registeredUsers').doc(uid).get();
      return docSnapshot.exists;
    } catch (e) {
      debugPrint('Failed to check if user is registered: $e');
      return false;
    }
  }

  /// Stream of registered users (for real-time updates)
  Stream<List<Map<String, dynamic>>> getRegisteredUsersStream() {
    return _firestore
        .collection('registeredUsers')
        .orderBy('lastLoginAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'uid': data['uid'] ?? doc.id,
          'email': data['email'] ?? '',
          'displayName': data['displayName'] ?? '',
          'photoURL': data['photoURL'],
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          'lastLoginAt': (data['lastLoginAt'] as Timestamp?)?.toDate(),
          'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
        };
      }).toList();
    });
  }

  /// Delete a registered user (admin function)
  Future<void> deleteRegisteredUser(String uid) async {
    try {
      await _firestore.collection('registeredUsers').doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete registered user: $e');
    }
  }
}
