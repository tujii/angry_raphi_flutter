import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/enums/raphcon_type.dart';
import '../models/raphcon_model.dart';

abstract class RaphconsRemoteDataSource {
  Future<List<RaphconModel>> getUserRaphcons(String userId);
  Future<List<RaphconModel>> getUserRaphconsByType(
      String userId, RaphconType type);
  Future<List<RaphconModel>> getAllRaphcons();
  Future<void> addRaphcon(
      String userId, String createdBy, String? comment, RaphconType type);
  Future<void> deleteRaphcon(String raphconId);
  Future<int> expireOldRaphcons();

  // Stream-based methods for real-time updates
  Stream<List<RaphconModel>> getUserRaphconsStream(String userId);
  Stream<List<RaphconModel>> getUserRaphconsByTypeStream(
      String userId, RaphconType type);
  Stream<List<RaphconModel>> getAllRaphconsStream();
}

@Injectable(as: RaphconsRemoteDataSource)
class RaphconsRemoteDataSourceImpl implements RaphconsRemoteDataSource {
  final FirebaseFirestore firestore;

  RaphconsRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<RaphconModel>> getUserRaphcons(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('raphcons')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RaphconModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get user raphcons: ${e.toString()}');
    }
  }

  @override
  Future<List<RaphconModel>> getUserRaphconsByType(
      String userId, RaphconType type) async {
    try {
      final querySnapshot = await firestore
          .collection('raphcons')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type.name)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RaphconModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(
          'Failed to get user raphcons by type: ${e.toString()}');
    }
  }

  @override
  Future<List<RaphconModel>> getAllRaphcons() async {
    try {
      final querySnapshot = await firestore
          .collection('raphcons')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RaphconModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get all raphcons: ${e.toString()}');
    }
  }

  @override
  Future<void> addRaphcon(String userId, String createdBy, String? comment,
      RaphconType type) async {
    try {
      final raphconModel = RaphconModel(
        id: null,
        userId: userId,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        comment: comment,
        type: type,
      );

      // Use batch to atomically add raphcon and update user count
      final batch = firestore.batch();

      // Add the raphcon
      final raphconRef = firestore.collection('raphcons').doc();
      batch.set(raphconRef, raphconModel.toMap());

      // Update user's raphcon count and lastRaphconAt
      final userRef = firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'raphconCount': FieldValue.increment(1),
        'lastRaphconAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to add raphcon: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteRaphcon(String raphconId) async {
    try {
      // Get the raphcon to find its userId before deleting
      final raphconDoc =
          await firestore.collection('raphcons').doc(raphconId).get();

      if (!raphconDoc.exists) {
        throw ServerException('Raphcon not found');
      }

      final userId = raphconDoc.data()!['userId'] as String;

      // Use batch to atomically delete raphcon and update user count
      final batch = firestore.batch();

      // Soft delete: set isActive to false instead of hard delete
      batch.update(firestore.collection('raphcons').doc(raphconId), {
        'isActive': false,
      });

      // Decrement user's raphcon count
      batch.update(firestore.collection('users').doc(userId), {
        'raphconCount': FieldValue.increment(-1),
      });

      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to delete raphcon: ${e.toString()}');
    }
  }

  @override
  Stream<List<RaphconModel>> getUserRaphconsStream(String userId) {
    return firestore
        .collection('raphcons')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RaphconModel.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((error) {
      throw ServerException(
          'Failed to stream user raphcons: ${error.toString()}');
    });
  }

  @override
  Stream<List<RaphconModel>> getUserRaphconsByTypeStream(
      String userId, RaphconType type) {
    return firestore
        .collection('raphcons')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type.name)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RaphconModel.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((error) {
      throw ServerException(
          'Failed to stream user raphcons by type: ${error.toString()}');
    });
  }

  @override
  Stream<List<RaphconModel>> getAllRaphconsStream() {
    return firestore
        .collection('raphcons')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RaphconModel.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((error) {
      throw ServerException(
          'Failed to stream all raphcons: ${error.toString()}');
    });
  }

  @override
  Future<int> expireOldRaphcons() async {
    try {
      // Calculate date one year ago from now
      final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
      
      // Query for active raphcons older than one year
      final querySnapshot = await firestore
          .collection('raphcons')
          .where('isActive', isEqualTo: true)
          .where('createdAt', isLessThan: oneYearAgo)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return 0;
      }

      // Use batch to update all expired raphcons and user counts
      final batch = firestore.batch();
      final userRaphconCounts = <String, int>{};

      // Mark raphcons as inactive and count per user
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isActive': false});
        
        final userId = doc.data()['userId'] as String;
        userRaphconCounts[userId] = (userRaphconCounts[userId] ?? 0) + 1;
      }

      // Update user raphcon counts
      for (final entry in userRaphconCounts.entries) {
        final userRef = firestore.collection('users').doc(entry.key);
        batch.update(userRef, {
          'raphconCount': FieldValue.increment(-entry.value),
        });
      }

      await batch.commit();
      return querySnapshot.docs.length;
    } catch (e) {
      throw ServerException('Failed to expire old raphcons: ${e.toString()}');
    }
  }
}
