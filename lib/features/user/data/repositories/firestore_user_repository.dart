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
      // Optimize query: filter active users with initials at database level
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('isActive', isEqualTo: true)
          .limit(50) // Limit for performance
          .get(const GetOptions(
              source: Source.server)); // Force server read for fresh data

      final users = <User>[];

      // Prepare to calculate actual raphcon counts
      final raphconCountsMap = <String, int>{};

      // Get all raphcons to calculate accurate counts
      try {
        final allRaphcons = await _firestore
            .collection('raphcons')
            .where('isActive', isEqualTo: true)
            .get(const GetOptions(source: Source.server));

        // Count raphcons per user
        for (final raphconDoc in allRaphcons.docs) {
          final userId = raphconDoc.data()['userId'] as String?;
          if (userId != null) {
            raphconCountsMap[userId] = (raphconCountsMap[userId] ?? 0) + 1;
          }
        }
      } catch (e) {
        // If raphcon counting fails, continue with stored counts
        print('Warning: Could not calculate real-time raphcon counts: $e');
      }

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final initials = data['initials'] as String? ?? '';
        final storedRaphconCount = data['raphconCount'] as int? ?? 0;

        // Use real-time count if available, otherwise use stored count
        final actualRaphconCount =
            raphconCountsMap[doc.id] ?? storedRaphconCount;

        // Skip auth users (they don't have initials and are not app users)
        if (initials.isEmpty || initials.length < 3) {
          continue;
        }

        final user = User(
          id: doc.id,
          initials: initials,
          avatarUrl: data['avatarUrl'],
          raphconCount: actualRaphconCount,
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          lastRaphconAt: (data['lastRaphconAt'] as Timestamp?)?.toDate(),
          isActive: true, // We already filtered for active users
        );
        users.add(user);
      }

      // Sort by actual raphcon count (descending)
      users.sort((a, b) => b.raphconCount.compareTo(a.raphconCount));

      return users;
    } catch (e) {
      // Fallback to server if cache fails
      try {
        final QuerySnapshot querySnapshot = await _firestore
            .collection(_usersCollection)
            .where('isActive', isEqualTo: true)
            .orderBy('raphconCount', descending: true)
            .limit(50)
            .get(const GetOptions(source: Source.server));

        final users = <User>[];

        for (final doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final initials = data['initials'] as String? ?? '';

          if (initials.isEmpty || initials.length < 3) {
            continue;
          }

          final user = User(
            id: doc.id,
            initials: initials,
            avatarUrl: data['avatarUrl'],
            raphconCount: data['raphconCount'] as int? ?? 0,
            createdAt:
                (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            lastRaphconAt: (data['lastRaphconAt'] as Timestamp?)?.toDate(),
            isActive: true,
          );
          users.add(user);
        }

        return users;
      } catch (serverError) {
        throw Exception('Failed to fetch users from Firestore: $serverError');
      }
    }
  }

  @override
  Stream<List<User>> getUsersStream() {
    return _firestore
        .collection(_usersCollection)
        .where('isActive', isEqualTo: true)
        .limit(50)
        .snapshots(includeMetadataChanges: false) // Ignore metadata changes
        .asyncMap((usersSnapshot) async {
      final users = <User>[];

      // Prepare to calculate actual raphcon counts
      final raphconCountsMap = <String, int>{};

      // Get all raphcons to calculate accurate counts
      try {
        final allRaphcons = await _firestore
            .collection('raphcons')
            .where('isActive', isEqualTo: true)
            .get(const GetOptions(source: Source.server));

        // Count raphcons per user
        for (final raphconDoc in allRaphcons.docs) {
          final userId = raphconDoc.data()['userId'] as String?;
          if (userId != null) {
            raphconCountsMap[userId] = (raphconCountsMap[userId] ?? 0) + 1;
          }
        }
      } catch (e) {
        // If raphcon counting fails, continue with stored counts
        print('Warning: Could not calculate real-time raphcon counts: $e');
      }

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        final initials = data['initials'] as String? ?? '';
        final storedRaphconCount = data['raphconCount'] as int? ?? 0;

        // Use real-time count if available, otherwise use stored count
        final actualRaphconCount =
            raphconCountsMap[doc.id] ?? storedRaphconCount;

        // Skip auth users (they don't have initials and are not app users)
        if (initials.isEmpty || initials.length < 3) {
          continue;
        }

        final user = User(
          id: doc.id,
          initials: initials,
          avatarUrl: data['avatarUrl'],
          raphconCount: actualRaphconCount,
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          lastRaphconAt: (data['lastRaphconAt'] as Timestamp?)?.toDate(),
          isActive: true,
        );
        users.add(user);
      }

      // Sort by actual raphcon count (descending)
      users.sort((a, b) => b.raphconCount.compareTo(a.raphconCount));

      return users;
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
        'lastRaphconAt': user.lastRaphconAt != null
            ? Timestamp.fromDate(user.lastRaphconAt!)
            : null,
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
      // First, delete all raphcons for this user
      final raphconQuery = await _firestore
          .collection('raphcons')
          .where('userId', isEqualTo: userId)
          .get();

      // Delete all raphcons in a batch
      final batch = _firestore.batch();
      for (final doc in raphconQuery.docs) {
        batch.delete(doc.reference);
      }

      // Add user deletion to the batch
      batch.delete(_firestore.collection(_usersCollection).doc(userId));

      // Execute all deletions atomically
      await batch.commit();

      return true;
    } catch (e) {
      throw Exception('Failed to delete user and raphcons: $e');
    }
  }
}
