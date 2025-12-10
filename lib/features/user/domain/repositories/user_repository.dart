import '../entities/user.dart';

/// Repository interface for user data operations
/// Following the Repository pattern from Clean Architecture
abstract class UserRepository {
  Future<List<User>> getUsers();
  Stream<List<User>> getUsersStream();
  Future<bool> addUser(User user);
  Future<bool> updateUserRaphcons(String userId, int newCount);
  Future<bool> deleteUser(String userId);
}
