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

      await firestore.collection('raphcons').add(raphconModel.toMap());
    } catch (e) {
      throw ServerException('Failed to add raphcon: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteRaphcon(String raphconId) async {
    try {
      await firestore.collection('raphcons').doc(raphconId).delete();
    } catch (e) {
      throw ServerException('Failed to delete raphcon: ${e.toString()}');
    }
  }
}
