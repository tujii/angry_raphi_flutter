import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignInWithPhone {
  final AuthRepository repository;

  SignInWithPhone(this.repository);

  Future<Either<Failure, String>> call(String phoneNumber) async {
    return await repository.signInWithPhone(phoneNumber);
  }
}
