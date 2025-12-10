import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

/// Firestore implementation of UserRepository
/// Data layer implementation following Clean Architecture
class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';

  const FirestoreUserRepository(this._firestore);

  @override
  Future<List<User>> getUsers() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_usersCollection)
          .orderBy('raphconCount', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return User(
          id: doc.id,
          initials: data['initials'] ??
              data['name'] ??
              '', // Support both new and legacy field names
          avatarUrl: data['avatarUrl'],
          raphconCount: data['raphconCount'] ?? 0,
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch users from Firestore: $e');
    }
  }

  @override
  Future<bool> addUser(User user) async {
    try {
      await _firestore.collection(_usersCollection).add({
        'initials': user.initials,
        'name': user.initials, // Keep legacy field for backwards compatibility
        'avatarUrl': user.avatarUrl,
        'raphconCount': user.raphconCount,
        'createdAt': Timestamp.fromDate(user.createdAt),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to add user to Firestore: $e');
    }
  }

  @override
  Future<bool> updateUserRaphcons(String userId, int newCount) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'raphconCount': newCount,
      });
      return true;
    } catch (e) {
      throw Exception('Failed to update user raphcons: $e');
    }
  }

  @override
  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
