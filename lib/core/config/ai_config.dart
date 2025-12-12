/// Configuration for AI services
/// 
/// To use Gemini AI:
/// 1. Get a free API key from https://makersuite.google.com/app/apikey
/// 2. Set the API key below
/// 3. Rebuild the app
/// 
/// If no API key is set, the app will fall back to template-based stories.
class AIConfig {
  /// Gemini API key
  /// Get yours at: https://makersuite.google.com/app/apikey
  /// Free tier includes 60 requests per minute
  static const String? geminiApiKey = null; // Set your API key here
  
  /// Whether AI features are enabled
  static bool get isEnabled => geminiApiKey != null && geminiApiKey.isNotEmpty;
}
