import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/core/constants/firebase_constants.dart';

void main() {
  group('FirebaseConstants', () {
    test('collection names are defined', () {
      expect(FirebaseConstants.usersCollection, isNotEmpty);
      expect(FirebaseConstants.raphconsCollection, isNotEmpty);
      expect(FirebaseConstants.adminsCollection, isNotEmpty);
    });

    test('collection names are valid Firestore identifiers', () {
      expect(FirebaseConstants.usersCollection, matches(RegExp(r'^[a-zA-Z0-9_]+$')));
      expect(FirebaseConstants.raphconsCollection, matches(RegExp(r'^[a-zA-Z0-9_]+$')));
      expect(FirebaseConstants.adminsCollection, matches(RegExp(r'^[a-zA-Z0-9_]+$')));
    });
  });
}
