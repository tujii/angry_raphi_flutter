import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/space_invitation_entity.dart';
import '../../domain/entities/space_role.dart';
import '../models/space_invitation_model.dart';
import '../models/space_member_model.dart';
import '../models/space_model.dart';

abstract class SpacesRemoteDataSource {
  Future<String> createSpace(SpaceModel space, SpaceMemberModel owner);
  Future<void> updateSpace(String spaceId, String name, String? description);
  Future<void> deleteSpace(String spaceId);
  Stream<List<SpaceModel>> watchMySpaces(String uid);
  Stream<SpaceModel?> watchSpace(String spaceId);
  Stream<SpaceMemberModel?> watchMembership(String spaceId, String uid);
  Stream<List<SpaceMemberModel>> watchMembers(String spaceId);
  Future<void> updateMemberRole(String spaceId, String uid, SpaceRole role);
  Future<void> removeMember(String spaceId, String uid);
  Future<String> createInvitation(SpaceInvitationModel invitation);
  Future<void> setInvitationStatus(
      String invitationId, InvitationStatus status);
  Stream<List<SpaceInvitationModel>> watchSpaceInvitations(String spaceId);
  Stream<List<SpaceInvitationModel>> watchMyInvitations(String email);
}

@Injectable(as: SpacesRemoteDataSource)
class SpacesRemoteDataSourceImpl implements SpacesRemoteDataSource {
  final FirebaseFirestore firestore;

  SpacesRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get _spaces =>
      firestore.collection(FirebaseConstants.spacesCollection);

  CollectionReference<Map<String, dynamic>> get _invitations =>
      firestore.collection(FirebaseConstants.invitationsCollection);

  CollectionReference<Map<String, dynamic>> _members(String spaceId) =>
      _spaces.doc(spaceId).collection(FirebaseConstants.spaceMembersCollection);

  @override
  Future<String> createSpace(SpaceModel space, SpaceMemberModel owner) async {
    try {
      final spaceRef = _spaces.doc();
      // Space and owner membership must be written atomically: the security
      // rules only accept each of them together with the other.
      final batch = firestore.batch();
      batch.set(spaceRef, {
        ...space.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.set(_members(spaceRef.id).doc(owner.uid), {
        ...SpaceMemberModel(
          uid: owner.uid,
          spaceId: spaceRef.id,
          role: SpaceRole.owner,
          displayName: owner.displayName,
          email: owner.email,
          photoUrl: owner.photoUrl,
          joinedAt: owner.joinedAt,
        ).toMap(),
        'joinedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      return spaceRef.id;
    } catch (e) {
      throw ServerException('Failed to create space: ${e.toString()}');
    }
  }

  @override
  Future<void> updateSpace(
      String spaceId, String name, String? description) async {
    try {
      await _spaces.doc(spaceId).update({
        'name': name,
        'description': description,
      });
    } catch (e) {
      throw ServerException('Failed to update space: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSpace(String spaceId) async {
    // TODO(spaces): delete subcollections server-side (Cloud Function).
    try {
      await _spaces.doc(spaceId).delete();
    } catch (e) {
      throw ServerException('Failed to delete space: ${e.toString()}');
    }
  }

  @override
  Stream<List<SpaceModel>> watchMySpaces(String uid) {
    return firestore
        .collectionGroup(FirebaseConstants.spaceMembersCollection)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .asyncMap((memberships) async {
      // Spaces are read one by one: the rules allow reading a space only
      // for its members, which a single-document read can prove.
      final spaceDocs = await Future.wait(memberships.docs.map((member) {
        final spaceId = member.reference.parent.parent!.id;
        return _spaces.doc(spaceId).get();
      }));
      final spaces = spaceDocs
          .where((doc) => doc.exists)
          .map((doc) => SpaceModel.fromMap(doc.data()!, doc.id))
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return spaces;
    });
  }

  @override
  Stream<SpaceModel?> watchSpace(String spaceId) {
    return _spaces.doc(spaceId).snapshots().map(
        (doc) => doc.exists ? SpaceModel.fromMap(doc.data()!, doc.id) : null);
  }

  @override
  Stream<SpaceMemberModel?> watchMembership(String spaceId, String uid) {
    return _members(spaceId).doc(uid).snapshots().map((doc) =>
        doc.exists ? SpaceMemberModel.fromMap(doc.data()!, doc.id) : null);
  }

  @override
  Stream<List<SpaceMemberModel>> watchMembers(String spaceId) {
    return _members(spaceId).snapshots().map((snapshot) {
      final members = snapshot.docs
          .map((doc) => SpaceMemberModel.fromMap(doc.data(), doc.id))
          .toList()
        // Highest role first, then alphabetically
        ..sort((a, b) {
          final byRole = b.role.index.compareTo(a.role.index);
          if (byRole != 0) return byRole;
          return a.displayName
              .toLowerCase()
              .compareTo(b.displayName.toLowerCase());
        });
      return members;
    });
  }

  @override
  Future<void> updateMemberRole(
      String spaceId, String uid, SpaceRole role) async {
    try {
      await _members(spaceId).doc(uid).update({'role': role.value});
    } catch (e) {
      throw ServerException('Failed to update member role: ${e.toString()}');
    }
  }

  @override
  Future<void> removeMember(String spaceId, String uid) async {
    try {
      await _members(spaceId).doc(uid).delete();
    } catch (e) {
      throw ServerException('Failed to remove member: ${e.toString()}');
    }
  }

  @override
  Future<String> createInvitation(SpaceInvitationModel invitation) async {
    try {
      final ref = await _invitations.add({
        ...invitation.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      throw ServerException('Failed to create invitation: ${e.toString()}');
    }
  }

  @override
  Future<void> setInvitationStatus(
      String invitationId, InvitationStatus status) async {
    try {
      await _invitations.doc(invitationId).update({'status': status.value});
    } catch (e) {
      throw ServerException('Failed to update invitation: ${e.toString()}');
    }
  }

  @override
  Stream<List<SpaceInvitationModel>> watchSpaceInvitations(String spaceId) {
    return _invitations
        .where('spaceId', isEqualTo: spaceId)
        .where('status', isEqualTo: InvitationStatus.pending.value)
        .snapshots()
        .map(_toInvitations);
  }

  @override
  Stream<List<SpaceInvitationModel>> watchMyInvitations(String email) {
    return _invitations
        .where('email', isEqualTo: email)
        .where('status', isEqualTo: InvitationStatus.pending.value)
        .snapshots()
        .map(_toInvitations);
  }

  List<SpaceInvitationModel> _toInvitations(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => SpaceInvitationModel.fromMap(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
