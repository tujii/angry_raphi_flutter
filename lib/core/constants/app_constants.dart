import 'package:flutter/material.dart';

/// Application-wide constants for AngryRaphi.
///
/// Centralizes all constants used throughout the application including:
/// - Brand colors and theme colors
/// - Animation asset paths
/// - Validation limits
/// - UI spacing and dimensions
/// - Route paths
///
/// All constants are defined as static members for easy access.
class AppConstants {
  // App Information
  /// The application display name
  static const String appName = 'AngryRaphi';
  
  /// Current application version
  static const String appVersion = '1.0.1';

  // Brand Colors
  /// Primary brand color - Dark red (#8B0000)
  static const Color primaryColor = Color(0xFF8B0000);
  
  /// Secondary accent color - Green (#4CAF50)
  static const Color secondaryColor = Color(0xFF4CAF50);
  
  /// Background color for main app areas
  static const Color backgroundColor = Color(0xFFF5F5F5);
  
  /// Card background color
  static const Color cardColor = Colors.white;
  
  /// Primary text color
  static const Color textColor = Color(0xFF212121);
  
  /// Subtitle and secondary text color
  static const Color subtitleColor = Color(0xFF757575);

  // Animation Asset Paths
  /// Path to angry face animation asset
  static const String angryFaceAnimation = 'assets/animations/angry_face.json';
  
  /// Path to loading spinner animation asset
  static const String loadingAnimation = 'assets/animations/loading_spinner.json';
  
  /// Path to success checkmark animation asset
  static const String successAnimation = 'assets/animations/success_checkmark.json';
  
  /// Path to user avatar animation asset
  static const String userAvatarAnimation = 'assets/animations/user_avatar.json';

  // Validation Limits
  /// Maximum allowed length for name fields
  static const int maxNameLength = 50;
  
  /// Maximum allowed length for description fields
  static const int maxDescriptionLength = 500;
  
  /// Maximum allowed image file size in megabytes
  static const int maxImageSizeMB = 5;

  // UI Spacing and Dimensions
  /// Standard padding for most UI elements (16.0)
  static const double defaultPadding = 16.0;
  
  /// Small padding for compact UI elements (8.0)
  static const double smallPadding = 8.0;
  
  /// Large padding for spacious UI elements (24.0)
  static const double largePadding = 24.0;
  
  /// Standard elevation for cards (4.0)
  static const double cardElevation = 4.0;
  
  /// Border radius for rounded corners (12.0)
  static const double borderRadius = 12.0;
  
  /// Standard height for buttons (48.0)
  static const double buttonHeight = 48.0;

  // Route Paths
  /// Home/landing page route
  static const String homeRoute = '/';
  
  /// Authentication page route
  static const String authRoute = '/auth';
  
  /// Users list page route
  static const String usersRoute = '/users';
  
  /// Add user page route
  static const String addUserRoute = '/add-user';
  
  /// User detail page route
  static const String userDetailRoute = '/user-detail';
  
  /// Raphcons list page route
  static const String raphconsRoute = '/raphcons';
  
  /// Add raphcon page route
  static const String addRaphconRoute = '/add-raphcon';
  
  /// Admin settings page route
  static const String adminRoute = '/admin';
}
