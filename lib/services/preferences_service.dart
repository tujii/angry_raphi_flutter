import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _languageKey = 'app_language';
  static const String _themeKey = 'app_theme';
  static const String _firstLaunchKey = 'app_first_launch';

  /// Get the saved language code (e.g., 'en', 'de', 'gsw')
  Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  /// Save the language code
  Future<bool> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_languageKey, languageCode);
  }

  /// Get the saved theme mode ('light' or 'dark')
  Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  /// Save the theme mode
  Future<bool> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_themeKey, theme);
  }

  /// Check if this is the first launch
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  /// Mark that the app has been launched
  Future<bool> setNotFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_firstLaunchKey, false);
  }
}
