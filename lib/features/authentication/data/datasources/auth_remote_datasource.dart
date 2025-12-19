import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../services/registered_users_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<String> signInWithPhone(String phoneNumber);
  Future<UserModel> verifyPhoneCode(String verificationId, String smsCode);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  final RegisteredUsersService _registeredUsersService;

  AuthRemoteDataSourceImpl(
    this._firebaseAuth,
    this._googleSignIn,
    this._firestore,
    this._registeredUsersService,
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

        // Save user to registeredUsers collection for tracking
        await _registeredUsersService.saveRegisteredUser(userCredential.user!);

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

        // Save user to registeredUsers collection for tracking
        await _registeredUsersService.saveRegisteredUser(userCredential.user!);

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
  Future<String> signInWithPhone(String phoneNumber) async {
    try {
      String verificationId = '';
      
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification on some devices
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = 'phoneVerificationFailed';
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'invalidPhoneNumber';
              break;
            case 'too-many-requests':
              errorMessage = 'tooManyRequests';
              break;
            default:
              errorMessage = e.message ?? 'phoneVerificationFailed';
          }
          throw AuthException(errorMessage);
        },
        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
      );
      
      // Wait a bit to ensure verificationId is set
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (verificationId.isEmpty) {
        throw AuthException('phoneVerificationFailed');
      }
      
      return verificationId;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'phoneVerificationFailed';
      switch (e.code) {
        case 'invalid-phone-number':
          errorMessage = 'invalidPhoneNumber';
          break;
        case 'too-many-requests':
          errorMessage = 'tooManyRequests';
          break;
        default:
          errorMessage = e.message ?? 'phoneVerificationFailed';
      }
      throw AuthException(errorMessage);
    } catch (e) {
      throw AuthException('phoneVerificationFailed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> verifyPhoneCode(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
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

      // Save user to registeredUsers collection for tracking
      await _registeredUsersService.saveRegisteredUser(userCredential.user!);

      return userModel;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'loginError';
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'invalidCredential';
          break;
        case 'session-expired':
          errorMessage = 'phoneVerificationFailed';
          break;
        default:
          errorMessage = e.message ?? 'unknownError';
      }
      throw AuthException(errorMessage);
    } catch (e) {
      throw AuthException('loginError: ${e.toString()}');
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

  // Removed _saveUserToFirestore method
  // Authentication users are managed by Firebase Auth
  // App users (with initials) are managed separately in the users collection
}
