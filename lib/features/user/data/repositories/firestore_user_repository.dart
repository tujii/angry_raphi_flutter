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
          .orderBy('createdAt', descending: false)
          .get();

      final users = <User>[];
      final seenUserIds = <String>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Skip if we've already processed this user ID (prevent duplicates)
        if (seenUserIds.contains(doc.id)) {
          continue;
        }
        seenUserIds.add(doc.id);

        // Get real-time raphcon count from raphcons collection (only active)
        final raphconQuery = await _firestore
            .collection('raphcons')
            .where('userId', isEqualTo: doc.id)
            .where('isActive', isEqualTo: true)
            .get();

        final initials = data['initials'] ?? data['name'] ?? '';

        // Skip auth users (they don't have initials and are not app users)
        if (initials.isEmpty) {
          continue;
        }

        final user = User(
          id: doc.id,
          initials: initials,
          avatarUrl: data['avatarUrl'],
          raphconCount: raphconQuery.size,
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          lastRaphconAt: (data['lastRaphconAt'] as Timestamp?)?.toDate(),
          isActive: data['isActive'] as bool? ?? true,
        );
        users.add(user);
      }

      // Remove duplicates based on initials (keep the one with most recent createdAt)
      final uniqueUsers = <String, User>{};
      for (final user in users) {
        final existing = uniqueUsers[user.initials];
        if (existing == null || user.createdAt.isAfter(existing.createdAt)) {
          uniqueUsers[user.initials] = user;
        }
      }
      final finalUsers = uniqueUsers.values.toList();

      // Sort by raphcon count descending
      finalUsers.sort((a, b) => b.raphconCount.compareTo(a.raphconCount));

      return finalUsers;
    } catch (e) {
      throw Exception('Failed to fetch users from Firestore: $e');
    }
  }

  @override
  Stream<List<User>> getUsersStream() {
    return _firestore
        .collection(_usersCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .asyncMap((usersSnapshot) async {
      final users = <User>[];
      final seenUserIds = <String>{};

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();

        // Skip if we've already processed this user ID (prevent duplicates)
        if (seenUserIds.contains(doc.id)) {
          continue;
        }
        seenUserIds.add(doc.id);

        // Get real-time raphcon count from raphcons collection (only active)
        final raphconQuery = await _firestore
            .collection('raphcons')
            .where('userId', isEqualTo: doc.id)
            .where('isActive', isEqualTo: true)
            .get();

        final initials = data['initials'] ?? data['name'] ?? '';

        // Skip auth users (they don't have initials and are not app users)
        if (initials.isEmpty) {
          continue;
        }

        final user = User(
          id: doc.id,
          initials: initials,
          avatarUrl: data['avatarUrl'],
          raphconCount: raphconQuery.size,
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          lastRaphconAt: (data['lastRaphconAt'] as Timestamp?)?.toDate(),
          isActive: data['isActive'] as bool? ?? true,
        );
        users.add(user);
      }

      // Remove duplicates based on initials (keep the one with most recent createdAt)
      final uniqueUsers = <String, User>{};
      for (final user in users) {
        final existing = uniqueUsers[user.initials];
        if (existing == null || user.createdAt.isAfter(existing.createdAt)) {
          uniqueUsers[user.initials] = user;
        }
      }
      final finalUsers = uniqueUsers.values.toList();

      // Sort by raphcon count descending
      finalUsers.sort((a, b) => b.raphconCount.compareTo(a.raphconCount));

      return finalUsers;
    });
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
        'lastRaphconAt': user.lastRaphconAt != null ? Timestamp.fromDate(user.lastRaphconAt!) : null,
        'isActive': user.isActive,
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
        'lastRaphconAt': Timestamp.now(),
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
