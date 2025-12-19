import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyPhoneCode {
  final AuthRepository repository;

  VerifyPhoneCode(this.repository);

  Future<Either<Failure, UserEntity>> call(
      String verificationId, String smsCode) async {
    return await repository.verifyPhoneCode(verificationId, smsCode);
  }
}
