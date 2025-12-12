import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/config/ai_config.dart';

/// Service for generating AI content using Google Gemini API
class GeminiAIService {
  final GenerativeModel? _model;
  final String? _apiKey;

  GeminiAIService(String? apiKey)
      : _apiKey = apiKey,
        _model = apiKey != null && apiKey.isNotEmpty
            ? GenerativeModel(
                model: AIConfig.geminiModel,
                apiKey: apiKey,
              )
            : null {
    // Debug output for API key status
  }

  /// Check if Gemini API is available
  bool get isAvailable => _model != null;

  /// Get debug information about API key status
  Map<String, dynamic> getDebugInfo() {
    return {
      'hasApiKey': _apiKey != null,
      'apiKeyLength': _apiKey?.length ?? 0,
      'apiKeyPrefix': _apiKey != null && _apiKey.length > 8
          ? '${_apiKey.substring(0, 8)}...'
          : _apiKey,
      'modelAvailable': _model != null,
      'geminiModel': AIConfig.geminiModel,
    };
  }

  /// Generate a funny story about a user's tech problems
  /// Returns null if generation fails or API is not available
  Future<String?> generateStory({
    required String userName,
    required String problemType,
    required int count,
    int variation = 0,
  }) async {
    if (_model == null) return null;

    try {
      final styles = [
        'witzig und sarkastisch',
        'übertrieben dramatisch', 
        'wie ein Sportkommentator',
        'poetisch und melancholisch',
        'wie eine Zeitungsschlagzeile'
      ];
      
      final currentStyle = styles[variation % styles.length];
      final randomSeed = DateTime.now().millisecond + variation + userName.hashCode;
      
      final prompt = '''
Generiere einen kurzen, lustigen deutschen Satz (maximal 15 Wörter) über Technik-Probleme.

Stil: $currentStyle
Benutzer: $userName  
Problem: $problemType
Anzahl: $count mal diese Woche
Variation: $variation
Einzigartigkeit-Seed: $randomSeed

Der Satz soll:
- Im gewählten Stil "$currentStyle" geschrieben sein
- Ein passendes Emoji am Anfang haben
- Kurz und prägnant sein
- ANDERS als alle vorherigen Varianten
- Kreativ und einzigartig formuliert

Verschiedene Ansätze je nach Variation:
- Variation 0: Klassisch ironisch
- Variation 1: Übertrieben theatralisch  
- Variation 2: Sportlich-commentiert
- Variation 3: Poetisch-melancholisch
- Variation 4: Nachrichtenstil

Generiere NUR den Satz, ohne Anführungszeichen. SEI KREATIV und vermeide Wiederholungen!
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text?.trim();

      if (text != null && text.isNotEmpty) {
        return _cleanResponse(text);
      }

      return null;
    } catch (e) {
      // Return null on error, will fall back to templates
      return null;
    }
  }

  /// Generate a story about the top user this week
  Future<String?> generateTopUserStory({
    required String userName,
    required int count,
    int variation = 0,
  }) async {
    if (_model == null) return null;

    try {
      final styles = [
        'humorvoll und leicht spöttisch',
        'sarkastisch aber freundlich',
        'übertrieben dramatisch',
        'wie ein Sportkmentator',
        'wie eine Zeitungsschlagzeile'
      ];

      final currentStyle = styles[variation % styles.length];
      final randomSeed = DateTime.now().millisecond + variation;

      final prompt = '''
Generiere einen kurzen, lustigen deutschen Satz (maximal 15 Wörter) über den "Rekordhalter der Woche".

Stil: $currentStyle
Benutzer: $userName
Raphcons: $count diese Woche
Variation: $variation (für Einzigartigkeit)
Random Seed: $randomSeed

Der Satz soll:
- Im gewählten Stil geschrieben sein
- Ein passendes Emoji am Anfang haben
- Kurz und prägnant sein
- ANDERS als vorherige Varianten

Verschiedene Ansätze:
- Variation 0: Klassisch ironisch
- Variation 1: Übertrieben sportlich
- Variation 2: Dramatisch theatralisch
- "🎯 $userName führt mit $count Raphcons! Technik ist nicht für jeden..."

Generiere NUR den Satz, ohne Anführungszeichen oder zusätzliche Erklärungen.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim();

      if (text != null && text.isNotEmpty) {
        return _cleanResponse(text);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clean up AI response by removing quotes and extra whitespace
  String _cleanResponse(String text) {
    return text.replaceAll('"', '').replaceAll("'", '').trim();
  }
}
