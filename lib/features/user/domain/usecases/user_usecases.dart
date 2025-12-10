import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use case for getting all users sorted by raphcon count
/// Follows Single Responsibility Principle and Clean Architecture
class GetUsersUseCase {
  final UserRepository _repository;

  const GetUsersUseCase(this._repository);

  Future<List<User>> execute() async {
    return await _repository.getUsers();
  }
}

/// Use case for adding a new user
class AddUserUseCase {
  final UserRepository _repository;

  const AddUserUseCase(this._repository);

  Future<bool> execute(User user) async {
    // Business logic validation could go here
    if (user.name.trim().isEmpty) {
      throw ArgumentError('User name cannot be empty');
    }
    return await _repository.addUser(user);
  }
}

/// Use case for updating user raphcon count
class UpdateUserRaphconsUseCase {
  final UserRepository _repository;

  const UpdateUserRaphconsUseCase(this._repository);

  Future<bool> execute(String userId, int newCount) async {
    if (newCount < 0) {
      throw ArgumentError('Raphcon count cannot be negative');
    }
    return await _repository.updateUserRaphcons(userId, newCount);
  }
}

/// Use case for deleting a user
class DeleteUserUseCase {
  final UserRepository _repository;

  const DeleteUserUseCase(this._repository);

  Future<bool> execute(String userId) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    return await _repository.deleteUser(userId);
  }
}
