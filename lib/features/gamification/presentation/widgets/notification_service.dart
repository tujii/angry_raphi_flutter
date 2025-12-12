import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Service for showing in-app notifications
class NotificationService {
  /// Show a toast notification
  static void showNotification({
    required String message,
    Color? backgroundColor,
    Color? textColor,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: backgroundColor ?? Colors.deepOrange,
      textColor: textColor ?? Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show success notification
  static void showSuccess(String message) {
    showNotification(
      message: message,
      backgroundColor: Colors.green,
    );
  }

  /// Show error notification
  static void showError(String message) {
    showNotification(
      message: message,
      backgroundColor: Colors.red,
    );
  }

  /// Show hardware fail notification
  static void showHardwareFail(String hardwareType, String userName) {
    showNotification(
      message: '$hardwareType hat wieder Ferien – $userName, pass auf!',
      backgroundColor: Colors.deepOrange,
    );
  }

  /// Show story notification
  static void showStory(String story) {
    showNotification(
      message: story,
      backgroundColor: Colors.purple,
    );
  }

  /// Show chaos points update
  static void showChaosPointsUpdate(int points, String rank) {
    showNotification(
      message: 'Chaos Points: $points | Rank: $rank',
      backgroundColor: Colors.blue,
    );
  }
}
