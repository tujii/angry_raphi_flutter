import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/space_invitation_entity.dart';
import '../../domain/entities/space_role.dart';
import '../models/invite_code_model.dart';
import '../models/space_invitation_model.dart';
import '../models/space_member_model.dart';
import '../models/space_model.dart';

abstract class SpacesRemoteDataSource {
  Future<String> createSpace(SpaceModel space, SpaceMemberModel owner);
  Future<void> updateSpace(String spaceId, String name, String? description);
  Future<void> deleteSpace(String spaceId, String ownerUid);
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
  Future<String> createInviteCode(InviteCodeModel invite);
  Stream<List<InviteCodeModel>> watchInviteCodes(String spaceId);
  Future<void> deactivateInviteCode(String spaceId, String code);
  Future<InviteCodeModel?> getInviteCode(String spaceId, String code);
  Future<void> joinWithInviteCode(
      String spaceId, String code, SpaceMemberModel member);
  Future<void> acceptInvitation(String invitationId, SpaceMemberModel member);
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

  CollectionReference<Map<String, dynamic>> _inviteCodes(String spaceId) =>
      _spaces
          .doc(spaceId)
          .collection(FirebaseConstants.spaceInviteCodesCollection);

  /// Firestore allows at most 500 writes per batch
  static const int _maxBatchWrites = 450;

  static const String _codeAlphabet =
      'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
  static const int _codeLength = 24;
  static final Random _random = Random.secure();

  /// Random, unguessable invite code (~138 bits)
  static String generateInviteCode() => List.generate(_codeLength,
      (_) => _codeAlphabet[_random.nextInt(_codeAlphabet.length)]).join();

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
  Future<void> deleteSpace(String spaceId, String ownerUid) async {
    try {
      final space = _spaces.doc(spaceId);
      final ownerMembership = _members(spaceId).doc(ownerUid);
      final content = await Future.wait([
        space.collection(FirebaseConstants.spaceRaphconsCollection).get(),
        space.collection(FirebaseConstants.spacePersonsCollection).get(),
        _inviteCodes(spaceId).get(),
        _invitations.where('spaceId', isEqualTo: spaceId).get(),
        _members(spaceId).get(),
      ]);
      final refs = content
          .expand((snapshot) => snapshot.docs)
          .map((doc) => doc.reference)
          .where((ref) => ref.path != ownerMembership.path)
          .toList();

      for (var i = 0; i < refs.length; i += _maxBatchWrites) {
        final batch = firestore.batch();
        for (final ref in refs.skip(i).take(_maxBatchWrites)) {
          batch.delete(ref);
        }
        await batch.commit();
      }

      // The owner's membership can only be removed together with the space.
      final last = firestore.batch()
        ..delete(space)
        ..delete(ownerMembership);
      await last.commit();
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

  @override
  Future<String> createInviteCode(InviteCodeModel invite) async {
    try {
      final code = generateInviteCode();
      await _inviteCodes(invite.spaceId).doc(code).set({
        ...invite.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return code;
    } catch (e) {
      throw ServerException('Failed to create invite link: ${e.toString()}');
    }
  }

  @override
  Stream<List<InviteCodeModel>> watchInviteCodes(String spaceId) {
    return _inviteCodes(spaceId).snapshots().map((snapshot) => snapshot.docs
        .map((doc) => InviteCodeModel.fromMap(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  @override
  Future<void> deactivateInviteCode(String spaceId, String code) async {
    try {
      await _inviteCodes(spaceId).doc(code).update({'active': false});
    } catch (e) {
      throw ServerException(
          'Failed to deactivate invite link: ${e.toString()}');
    }
  }

  @override
  Future<InviteCodeModel?> getInviteCode(String spaceId, String code) async {
    try {
      final doc = await _inviteCodes(spaceId).doc(code).get();
      return doc.exists ? InviteCodeModel.fromMap(doc.data()!, doc.id) : null;
    } catch (e) {
      throw ServerException('Failed to load invite link: ${e.toString()}');
    }
  }

  @override
  Future<void> joinWithInviteCode(
      String spaceId, String code, SpaceMemberModel member) async {
    try {
      await _members(spaceId).doc(member.uid).set({
        ...member.toMap(),
        'inviteCode': code,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to join space: ${e.toString()}');
    }
  }

  @override
  Future<void> acceptInvitation(
      String invitationId, SpaceMemberModel member) async {
    try {
      // Membership and status change must be written together: the rules
      // accept each of them only with the other.
      final batch = firestore.batch()
        ..set(_members(member.spaceId).doc(member.uid), {
          ...member.toMap(),
          'invitationId': invitationId,
          'joinedAt': FieldValue.serverTimestamp(),
        })
        ..update(_invitations.doc(invitationId),
            {'status': InvitationStatus.accepted.value});
      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to accept invitation: ${e.toString()}');
    }
  }
}
