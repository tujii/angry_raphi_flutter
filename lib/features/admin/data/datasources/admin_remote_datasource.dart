import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/admin_model.dart';

abstract class AdminRemoteDataSource {
  Future<bool> checkAdminStatus(String userId);
  Future<void> addAdmin(String userId, String email, String displayName);
  Future<void> removeAdmin(String userId);
  Future<List<AdminModel>> getAllAdmins();
}

@Injectable(as: AdminRemoteDataSource)
class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;

  AdminRemoteDataSourceImpl(this.firestore);

  @override
  Future<bool> checkAdminStatus(String userId) async {
    try {
      final doc = await firestore.collection('admins').doc(userId).get();
      return doc.exists && (doc.data()?['isActive'] as bool? ?? false);
    } catch (e) {
      throw ServerException('Failed to check admin status: ${e.toString()}');
    }
  }

  @override
  Future<void> addAdmin(String userId, String email, String displayName) async {
    try {
      final adminModel = AdminModel(
        id: userId,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await firestore.collection('admins').doc(userId).set(adminModel.toMap());
    } catch (e) {
      throw ServerException('Failed to add admin: ${e.toString()}');
    }
  }

  @override
  Future<void> removeAdmin(String userId) async {
    try {
      await firestore
          .collection('admins')
          .doc(userId)
          .update({'isActive': false});
    } catch (e) {
      throw ServerException('Failed to remove admin: ${e.toString()}');
    }
  }

  @override
  Future<List<AdminModel>> getAllAdmins() async {
    try {
      final querySnapshot = await firestore
          .collection('admins')
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AdminModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get all admins: ${e.toString()}');
    }
  }
}
