import 'package:angry_raphi/core/data/data_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataScope', () {
    test('legacy scope uses the global collections', () {
      expect(DataScope.legacy.personsPath, 'users');
      expect(DataScope.legacy.raphconsPath, 'raphcons');
      expect(DataScope.legacy.isSpace, isFalse);
      expect(DataScope.legacy.spaceId, isNull);
    });

    test('space scope uses the subcollections of the space', () {
      final scope = DataScope.space('abc');
      expect(scope.personsPath, 'spaces/abc/persons');
      expect(scope.raphconsPath, 'spaces/abc/raphcons');
      expect(scope.isSpace, isTrue);
      expect(scope.spaceId, 'abc');
    });

    test('scopes compare by paths', () {
      expect(DataScope.space('abc'), DataScope.space('abc'));
      expect(DataScope.space('abc'), isNot(DataScope.space('xyz')));
      expect(DataScope.space('abc'), isNot(DataScope.legacy));
    });
  });
}
