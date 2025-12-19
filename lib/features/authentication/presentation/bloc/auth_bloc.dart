import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_in_with_phone.dart';
import '../../domain/usecases/verify_phone_code.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/get_current_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithPhone _signInWithPhone;
  final VerifyPhoneCode _verifyPhoneCode;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;
  final AuthRepository _authRepository;
  StreamSubscription? _authStateSubscription;

  AuthBloc(
    this._signInWithGoogle,
    this._signInWithPhone,
    this._verifyPhoneCode,
    this._signOut,
    this._getCurrentUser,
    this._authRepository,
  ) : super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthPhoneSignInRequested>(_onAuthPhoneSignInRequested);
    on<AuthVerifyPhoneCode>(_onAuthVerifyPhoneCode);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthUserChanged>(_onAuthUserChanged);

    // Listen to auth state changes
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      add(AuthUserChanged(user));
    });
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _getCurrentUser();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _signInWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthPhoneSignInRequested(
    AuthPhoneSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _signInWithPhone(event.phoneNumber);
    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (verificationId) async {
        // Empty verificationId means auto-verification succeeded
        if (verificationId.isEmpty) {
          // User is already signed in, get current user
          try {
            final userResult = await _getCurrentUser();
            userResult.fold(
              (failure) => emit(AuthError(failure.message)),
              (user) {
                if (user != null) {
                  emit(AuthAuthenticated(user));
                } else {
                  emit(AuthError('phoneVerificationFailed'));
                }
              },
            );
          } catch (e) {
            emit(AuthError('phoneVerificationFailed'));
          }
        } else {
          emit(AuthPhoneCodeSent(
            verificationId: verificationId,
            phoneNumber: event.phoneNumber,
          ));
        }
      },
    );
  }

  Future<void> _onAuthVerifyPhoneCode(
    AuthVerifyPhoneCode event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _verifyPhoneCode(event.verificationId, event.smsCode);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _signOut();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
