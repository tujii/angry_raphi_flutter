/// Configuration for AI services
/// 
/// To use Gemini AI:
/// Option 1 - Environment Variable (Recommended for Codespaces/CI):
///   Set GEMINI_API_KEY environment variable
/// 
/// Option 2 - Hardcoded (For local development):
///   1. Get a free API key from https://makersuite.google.com/app/apikey
///   2. Set the API key in _hardcodedApiKey below
///   3. Rebuild the app
/// 
/// If no API key is set, the app will fall back to template-based stories.
class AIConfig {
  /// Hardcoded API key (only for local development)
  /// Leave as null to use environment variable
  static const String? _hardcodedApiKey = null; // Set your API key here if needed
  
  /// Gemini API key - reads from environment variable or fallback to hardcoded value
  /// Get yours at: https://makersuite.google.com/app/apikey
  /// Free tier includes 60 requests per minute
  static String? get geminiApiKey {
    // Try to read from environment variable first (for Codespaces/CI)
    const envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }
    // Fallback to hardcoded key
    return _hardcodedApiKey;
  }
  
  /// Gemini model to use
  /// 'gemini-1.5-flash' is recommended for fast, cost-effective generation
  static const String geminiModel = 'gemini-1.5-flash';
}
