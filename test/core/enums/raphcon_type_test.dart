import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/core/enums/raphcon_type.dart';

void main() {
  group('RaphconType', () {
    test('has correct string values', () {
      expect(RaphconType.headset.value, equals('headset'));
      expect(RaphconType.webcam.value, equals('webcam'));
      expect(RaphconType.otherPeripherals.value, equals('otherPeripherals'));
      expect(RaphconType.mouseHighlighter.value, equals('mouseHighlighter'));
      expect(RaphconType.lateMeeting.value, equals('lateMeeting'));
    });

    group('fromString', () {
      test('converts valid string to enum', () {
        expect(RaphconType.fromString('headset'), equals(RaphconType.headset));
        expect(RaphconType.fromString('webcam'), equals(RaphconType.webcam));
        expect(RaphconType.fromString('otherPeripherals'), equals(RaphconType.otherPeripherals));
        expect(RaphconType.fromString('mouseHighlighter'), equals(RaphconType.mouseHighlighter));
        expect(RaphconType.fromString('lateMeeting'), equals(RaphconType.lateMeeting));
      });

      test('returns otherPeripherals for invalid string', () {
        expect(RaphconType.fromString('invalid'), equals(RaphconType.otherPeripherals));
        expect(RaphconType.fromString(''), equals(RaphconType.otherPeripherals));
        expect(RaphconType.fromString('unknown'), equals(RaphconType.otherPeripherals));
      });
      
      test('maps old types to new types for backward compatibility', () {
        // Old peripheral types should map to otherPeripherals
        expect(RaphconType.fromString('mouse'), equals(RaphconType.otherPeripherals));
        expect(RaphconType.fromString('keyboard'), equals(RaphconType.otherPeripherals));
        expect(RaphconType.fromString('speakers'), equals(RaphconType.otherPeripherals));
        expect(RaphconType.fromString('network'), equals(RaphconType.otherPeripherals));
        expect(RaphconType.fromString('software'), equals(RaphconType.otherPeripherals));
        expect(RaphconType.fromString('hardware'), equals(RaphconType.otherPeripherals));
        expect(RaphconType.fromString('other'), equals(RaphconType.otherPeripherals));
        
        // Microphone should map to headset
        expect(RaphconType.fromString('microphone'), equals(RaphconType.headset));
      });
    });

    group('iconName', () {
      test('returns correct icon names', () {
        expect(RaphconType.headset.iconName, equals('headset'));
        expect(RaphconType.webcam.iconName, equals('videocam'));
        expect(RaphconType.otherPeripherals.iconName, equals('devices'));
        expect(RaphconType.mouseHighlighter.iconName, equals('highlight_mouse_cursor'));
        expect(RaphconType.lateMeeting.iconName, equals('schedule'));
      });
    });
  });
}
