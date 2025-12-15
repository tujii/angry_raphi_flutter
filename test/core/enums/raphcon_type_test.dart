import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/core/enums/raphcon_type.dart';

void main() {
  group('RaphconType', () {
    test('has correct string values', () {
      expect(RaphconType.mouse.value, equals('mouse'));
      expect(RaphconType.keyboard.value, equals('keyboard'));
      expect(RaphconType.microphone.value, equals('microphone'));
      expect(RaphconType.headset.value, equals('headset'));
      expect(RaphconType.webcam.value, equals('webcam'));
      expect(RaphconType.speakers.value, equals('speakers'));
      expect(RaphconType.network.value, equals('network'));
      expect(RaphconType.software.value, equals('software'));
      expect(RaphconType.hardware.value, equals('hardware'));
      expect(RaphconType.other.value, equals('other'));
    });

    group('fromString', () {
      test('converts valid string to enum', () {
        expect(RaphconType.fromString('mouse'), equals(RaphconType.mouse));
        expect(RaphconType.fromString('keyboard'), equals(RaphconType.keyboard));
        expect(RaphconType.fromString('microphone'), equals(RaphconType.microphone));
        expect(RaphconType.fromString('headset'), equals(RaphconType.headset));
        expect(RaphconType.fromString('webcam'), equals(RaphconType.webcam));
        expect(RaphconType.fromString('speakers'), equals(RaphconType.speakers));
        expect(RaphconType.fromString('network'), equals(RaphconType.network));
        expect(RaphconType.fromString('software'), equals(RaphconType.software));
        expect(RaphconType.fromString('hardware'), equals(RaphconType.hardware));
        expect(RaphconType.fromString('other'), equals(RaphconType.other));
      });

      test('returns other for invalid string', () {
        expect(RaphconType.fromString('invalid'), equals(RaphconType.other));
        expect(RaphconType.fromString(''), equals(RaphconType.other));
        expect(RaphconType.fromString('unknown'), equals(RaphconType.other));
      });
    });

    group('iconName', () {
      test('returns correct icon names', () {
        expect(RaphconType.mouse.iconName, equals('mouse'));
        expect(RaphconType.keyboard.iconName, equals('keyboard'));
        expect(RaphconType.microphone.iconName, equals('mic'));
        expect(RaphconType.headset.iconName, equals('headset'));
        expect(RaphconType.webcam.iconName, equals('videocam'));
        expect(RaphconType.speakers.iconName, equals('volume_up'));
        expect(RaphconType.network.iconName, equals('wifi_off'));
        expect(RaphconType.software.iconName, equals('computer'));
        expect(RaphconType.hardware.iconName, equals('hardware'));
        expect(RaphconType.other.iconName, equals('help_outline'));
      });
    });
  });
}
