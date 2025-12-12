import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/enums/raphcon_type.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/hardware_fail_model.dart';
import '../models/story_model.dart';
import '../models/chaos_user_model.dart';

/// Remote data source for gamification operations
abstract class GamificationRemoteDataSource {
  Future<void> addHardwareFail({
    required String userId,
    required RaphconType type,
  });

  Future<List<HardwareFailModel>> getHardwareFails({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<StoryModel> createStory({
    required String userId,
    required String text,
  });

  Future<StoryModel?> getLatestStory({
    required String userId,
  });

  Future<ChaosUserModel> getUserChaosPoints({
    required String userId,
  });

  Stream<ChaosUserModel> getUserChaosPointsStream({
    required String userId,
  });

  Stream<StoryModel?> getLatestStoryStream({
    required String userId,
  });
}

/// Implementation of gamification remote data source
class GamificationRemoteDataSourceImpl implements GamificationRemoteDataSource {
  final FirebaseFirestore firestore;

  GamificationRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> addHardwareFail({
    required String userId,
    required RaphconType type,
  }) async {
    try {
      final batch = firestore.batch();

      // Add hardware fail
      final failRef = firestore
          .collection(FirebaseConstants.hardwareFailsCollection)
          .doc();
      final failModel = HardwareFailModel(
        id: failRef.id,
        userId: userId,
        type: type,
        timestamp: DateTime.now(),
      );
      batch.set(failRef, failModel.toFirestore());

      // Update user chaos points atomically
      final userRef = firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId);
      batch.update(userRef, {
        'totalChaosPoints': FieldValue.increment(1),
      });

      await batch.commit();
    } catch (e) {
      throw ServerException(message: 'Failed to add hardware fail: $e');
    }
  }

  @override
  Future<List<HardwareFailModel>> getHardwareFails({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await firestore
          .collection(FirebaseConstants.hardwareFailsCollection)
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HardwareFailModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get hardware fails: $e');
    }
  }

  @override
  Future<StoryModel> createStory({
    required String userId,
    required String text,
  }) async {
    try {
      final storyRef = firestore
          .collection(FirebaseConstants.storiesCollection)
          .doc();
      final storyModel = StoryModel(
        id: storyRef.id,
        userId: userId,
        text: text,
        timestamp: DateTime.now(),
      );
      await storyRef.set(storyModel.toFirestore());
      return storyModel;
    } catch (e) {
      throw ServerException(message: 'Failed to create story: $e');
    }
  }

  @override
  Future<StoryModel?> getLatestStory({
    required String userId,
  }) async {
    try {
      final snapshot = await firestore
          .collection(FirebaseConstants.storiesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return StoryModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw ServerException(message: 'Failed to get latest story: $e');
    }
  }

  @override
  Future<ChaosUserModel> getUserChaosPoints({
    required String userId,
  }) async {
    try {
      final snapshot = await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .get();

      if (!snapshot.exists) {
        throw ServerException(message: 'User not found');
      }

      return ChaosUserModel.fromFirestore(snapshot);
    } catch (e) {
      throw ServerException(message: 'Failed to get user chaos points: $e');
    }
  }

  @override
  Stream<ChaosUserModel> getUserChaosPointsStream({
    required String userId,
  }) {
    try {
      return firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          throw ServerException(message: 'User not found');
        }
        return ChaosUserModel.fromFirestore(snapshot);
      });
    } catch (e) {
      throw ServerException(message: 'Failed to stream user chaos points: $e');
    }
  }

  @override
  Stream<StoryModel?> getLatestStoryStream({
    required String userId,
  }) {
    try {
      return firestore
          .collection(FirebaseConstants.storiesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return null;
        }
        return StoryModel.fromFirestore(snapshot.docs.first);
      });
    } catch (e) {
      throw ServerException(message: 'Failed to stream latest story: $e');
    }
  }
}
