import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl(
    this._firebaseAuth,
    this._googleSignIn,
    this._firestore,
  );

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Web-specific implementation
      if (kIsWeb) {
        // For web, use Firebase Auth directly with Google provider
        final GoogleAuthProvider provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');

        final UserCredential userCredential =
            await _firebaseAuth.signInWithPopup(provider);

        if (userCredential.user == null) {
          throw AuthException('loginError');
        }

        // Check if user is admin
        final isAdmin = await _checkIsAdmin(userCredential.user!.uid);

        final userModel = UserModel.fromFirebaseUser(
          userCredential.user!,
          isAdmin,
        );

        // Save user data to Firestore
        await _saveUserToFirestore(userModel);

        return userModel;
      } else {
        // Mobile implementation
        // Ensure we're signed out first to force account picker
        await _googleSignIn.signOut();

        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw AuthException('signInCancelled');
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        if (googleAuth.accessToken == null || googleAuth.idToken == null) {
          throw AuthException('signInCancelled');
        }

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);

        if (userCredential.user == null) {
          throw AuthException('loginError');
        }

        // Check if user is admin
        final isAdmin = await _checkIsAdmin(userCredential.user!.uid);

        final userModel = UserModel.fromFirebaseUser(
          userCredential.user!,
          isAdmin,
        );

        // Save user data to Firestore
        await _saveUserToFirestore(userModel);

        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'loginError';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'credentialAlreadyInUse';
          break;
        case 'invalid-credential':
          errorMessage = 'invalidCredential';
          break;
        case 'operation-not-allowed':
          errorMessage = 'operationNotAllowed';
          break;
        case 'user-disabled':
          errorMessage = 'userDisabled';
          break;
        case 'user-not-found':
          errorMessage = 'userNotFound';
          break;
        case 'wrong-password':
          errorMessage = 'wrongPassword';
          break;
        default:
          errorMessage = e.message ?? 'unknownError';
      }
      throw AuthException(errorMessage);
    } on Exception catch (e) {
      throw AuthException('loginError: ${e.toString()}');
    } catch (e) {
      throw AuthException('unknownError');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final isAdmin = await _checkIsAdmin(firebaseUser.uid);
      return UserModel.fromFirebaseUser(firebaseUser, isAdmin);
    } catch (e) {
      throw AuthException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      final isAdmin = await _checkIsAdmin(firebaseUser.uid);
      return UserModel.fromFirebaseUser(firebaseUser, isAdmin);
    });
  }

  Future<bool> _checkIsAdmin(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.adminsCollection)
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveUserToFirestore(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      // Log error but don't throw - user is already signed in
      // Failed to save user to Firestore - silent in production
    }
  }
}
