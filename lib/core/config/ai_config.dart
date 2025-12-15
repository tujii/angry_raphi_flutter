/// Configuration for AI services
/// 
/// ⚠️ SECURITY NOTICE:
/// NEVER commit real API keys to version control!
/// This file is safe to commit because _hardcodedApiKey is set to null.
/// 
/// To use Gemini AI:
/// 
/// Option 1 - Local File (Recommended for Local Development):
///   Create a file named 'gemini_api_key' in the project root (already in .gitignore)
///   Add your API key to that file
/// 
/// Option 2 - Environment Variable (Recommended for Production/CI):
///   Set GEMINI_API_KEY environment variable
///   For GitHub Codespaces: Add as repository secret
///   For local: export GEMINI_API_KEY='your-key' && flutter run --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
/// 
/// Option 3 - Hardcoded (NOT RECOMMENDED - Risk of accidental commit):
///   Get a free API key from https://makersuite.google.com/app/apikey
///   Set the API key in _hardcodedApiKey below
///   Be extremely careful not to commit this change
/// 
/// If no API key is set, the app will fall back to template-based stories.
class AIConfig {
  /// ⚠️ WARNING: Only use for local development and NEVER commit a real key!
  /// It's much safer to use Option 1 or 2 above.
  /// Leave as null to use environment variable or local file.
  static const String? _hardcodedApiKey = null; // DO NOT commit real keys here!
  
  /// Gemini API key - reads from environment variable or fallback to hardcoded value
  /// Get yours at: https://makersuite.google.com/app/apikey
  /// Free tier includes 60 requests per minute
  static String? get geminiApiKey {
    // Try to read from environment variable first (for Codespaces/CI)
    const envKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
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
