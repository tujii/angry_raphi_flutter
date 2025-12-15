import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/core/config/ai_config.dart';

void main() {
  group('AIConfig', () {
    test('geminiModel is defined', () {
      expect(AIConfig.geminiModel, isNotEmpty);
      expect(AIConfig.geminiModel, equals('gemini-1.5-flash'));
    });

    test('geminiApiKey returns string or null', () {
      final apiKey = AIConfig.geminiApiKey;
      expect(apiKey, anyOf(isNull, isA<String>()));
    });
  });
}
