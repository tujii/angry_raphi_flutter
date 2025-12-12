import 'package:google_generative_ai/google_generative_ai.dart';

/// Service for generating AI content using Google Gemini API
class GeminiAIService {
  final GenerativeModel? _model;
  
  GeminiAIService(String? apiKey)
      : _model = apiKey != null && apiKey.isNotEmpty
            ? GenerativeModel(
                model: 'gemini-1.5-flash',
                apiKey: apiKey,
              )
            : null;

  /// Check if Gemini API is available
  bool get isAvailable => _model != null;

  /// Generate a funny story about a user's tech problems
  /// Returns null if generation fails or API is not available
  Future<String?> generateStory({
    required String userName,
    required String problemType,
    required int count,
  }) async {
    if (_model == null) return null;

    try {
      final prompt = '''
Generiere einen kurzen, lustigen deutschen Satz (maximal 15 Wörter) über Technik-Probleme.

Benutzer: $userName
Problem: $problemType
Anzahl: $count mal diese Woche

Der Satz soll:
- Humorvoll und freundlich sein
- Ein passendes Emoji am Anfang haben
- Kurz und prägnant sein
- Im informellen "Du"-Stil geschrieben sein

Beispiele:
- "🎧 M.J. hat den Krieg 3x gegen sein Headset verloren diese Woche!"
- "💻 S.C. hat seine Software nicht im Griff, sogar 5x!"

Generiere NUR den Satz, ohne Anführungszeichen oder zusätzliche Erklärungen.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text?.trim();
      
      if (text != null && text.isNotEmpty) {
        // Clean up the response (remove quotes if present)
        return text.replaceAll('"', '').replaceAll("'", '').trim();
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
  }) async {
    if (_model == null) return null;

    try {
      final prompt = '''
Generiere einen kurzen, lustigen deutschen Satz (maximal 15 Wörter) über den "Rekordhalter der Woche".

Benutzer: $userName
Raphcons: $count diese Woche

Der Satz soll:
- Humorvoll und leicht spöttisch sein
- Ein passendes Emoji am Anfang haben
- Kurz und prägnant sein

Beispiele:
- "🏆 Rekordhalter der Woche: $userName mit $count Raphcons. Glückwunsch? 🤔"
- "🎯 $userName führt mit $count Raphcons! Technik ist nicht für jeden..."

Generiere NUR den Satz, ohne Anführungszeichen oder zusätzliche Erklärungen.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text?.trim();
      
      if (text != null && text.isNotEmpty) {
        return text.replaceAll('"', '').replaceAll("'", '').trim();
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}
