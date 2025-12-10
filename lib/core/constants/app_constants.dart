import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'AngryRaphi';
  static const Color primaryColor = Color(0xFF8B0000); // Dark Red
  static const Color secondaryColor = Color(0xFF4CAF50); // Green
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF212121);
  static const Color subtitleColor = Color(0xFF757575);

  // Animation Paths
  static const String angryFaceAnimation = 'assets/animations/angry_face.json';
  static const String loadingAnimation =
      'assets/animations/loading_spinner.json';
  static const String successAnimation =
      'assets/animations/success_checkmark.json';
  static const String userAvatarAnimation =
      'assets/animations/user_avatar.json';

  // Validation
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const int maxImageSizeMB = 5;

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double cardElevation = 4.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 48.0;

  // Routes
  static const String homeRoute = '/';
  static const String authRoute = '/auth';
  static const String usersRoute = '/users';
  static const String addUserRoute = '/add-user';
  static const String userDetailRoute = '/user-detail';
  static const String raphconsRoute = '/raphcons';
  static const String addRaphconRoute = '/add-raphcon';
  static const String adminRoute = '/admin';
}
