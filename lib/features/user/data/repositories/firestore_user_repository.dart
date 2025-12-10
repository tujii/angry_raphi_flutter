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
          name: data['name'] ?? '',
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
        'name': user.name,
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

  @override
  Future<void> addSampleData() async {
    try {
      final sampleUsers = _getSampleUsersData();

      for (final userData in sampleUsers) {
        await _firestore.collection(_usersCollection).add(userData);
      }
    } catch (e) {
      throw Exception('Failed to add sample data: $e');
    }
  }

  List<Map<String, dynamic>> _getSampleUsersData() {
    return [
      {
        'name': 'Max Mustermann',
        'avatarUrl': null,
        'raphconCount': 127,
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 30))),
      },
      {
        'name': 'Anna Schmidt',
        'avatarUrl': null,
        'raphconCount': 89,
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 25))),
      },
      {
        'name': 'Marc Weber',
        'avatarUrl': null,
        'raphconCount': 156,
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 20))),
      },
      {
        'name': 'Lisa Müller',
        'avatarUrl': null,
        'raphconCount': 73,
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 15))),
      },
      {
        'name': 'Ben Fischer',
        'avatarUrl': null,
        'raphconCount': 134,
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 10))),
      },
      {
        'name': 'Sarah Wagner',
        'avatarUrl': null,
        'raphconCount': 92,
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 8))),
      },
      {
        'name': 'Tom Becker',
        'avatarUrl': null,
        'raphconCount': 45,
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 5))),
      },
      {
        'name': 'Nina Hoffmann',
        'avatarUrl': null,
        'raphconCount': 67,
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 3))),
      },
    ];
  }
}
