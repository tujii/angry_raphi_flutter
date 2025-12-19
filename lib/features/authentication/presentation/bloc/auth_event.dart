import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {}

class AuthPhoneSignInRequested extends AuthEvent {
  final String phoneNumber;

  AuthPhoneSignInRequested(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class AuthVerifyPhoneCode extends AuthEvent {
  final String verificationId;
  final String smsCode;

  AuthVerifyPhoneCode({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object> get props => [verificationId, smsCode];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final UserEntity? user;

  AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}
