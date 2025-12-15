import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/admin_model.dart';

abstract class AdminRemoteDataSource {
  Future<bool> checkAdminStatus(String email);
  Future<void> addAdmin(String userId, String email, String displayName);
  Future<void> removeAdmin(String email);
  Future<List<AdminModel>> getAllAdmins();
}

@Injectable(as: AdminRemoteDataSource)
class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;

  AdminRemoteDataSourceImpl(this.firestore);

  @override
  Future<bool> checkAdminStatus(String email) async {
    try {
      final querySnapshot = await firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
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
  Future<void> removeAdmin(String email) async {
    try {
      final querySnapshot = await firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        await firestore
            .collection('admins')
            .doc(querySnapshot.docs.first.id)
            .update({'isActive': false});
      } else {
        throw ServerException('Admin with email $email not found');
      }
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
