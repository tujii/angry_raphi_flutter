import 'package:angry_raphi/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConstants', () {
    test('app info constants are defined', () {
      expect(AppConstants.appName, isNotEmpty);
      expect(AppConstants.appVersion, isNotEmpty);
    });

    test('color constants are defined', () {
      expect(AppConstants.primaryColor, isA<Color>());
      expect(AppConstants.secondaryColor, isA<Color>());
      expect(AppConstants.backgroundColor, isA<Color>());
      expect(AppConstants.cardColor, isA<Color>());
      expect(AppConstants.textColor, isA<Color>());
      expect(AppConstants.subtitleColor, isA<Color>());
    });

    test('animation paths are defined', () {
      expect(AppConstants.angryFaceAnimation, contains('assets'));
      expect(AppConstants.loadingAnimation, contains('assets'));
      expect(AppConstants.successAnimation, contains('assets'));
      expect(AppConstants.userAvatarAnimation, contains('assets'));
    });

    test('validation limits are reasonable', () {
      expect(AppConstants.maxNameLength, greaterThan(0));
      expect(AppConstants.maxDescriptionLength, greaterThan(0));
      expect(AppConstants.maxImageSizeMB, greaterThan(0));
    });

    test('UI spacing constants are positive', () {
      expect(AppConstants.defaultPadding, greaterThan(0));
      expect(AppConstants.smallPadding, greaterThan(0));
      expect(AppConstants.largePadding, greaterThan(0));
      expect(AppConstants.cardElevation, greaterThanOrEqualTo(0));
      expect(AppConstants.borderRadius, greaterThanOrEqualTo(0));
      expect(AppConstants.buttonHeight, greaterThan(0));
    });

    test('UI spacing follows logical order', () {
      expect(AppConstants.smallPadding, lessThan(AppConstants.defaultPadding));
      expect(AppConstants.defaultPadding, lessThan(AppConstants.largePadding));
    });

    test('route paths are defined', () {
      expect(AppConstants.homeRoute, isNotEmpty);
      expect(AppConstants.authRoute, isNotEmpty);
      expect(AppConstants.usersRoute, isNotEmpty);
      expect(AppConstants.addUserRoute, isNotEmpty);
      expect(AppConstants.userDetailRoute, isNotEmpty);
      expect(AppConstants.raphconsRoute, isNotEmpty);
      expect(AppConstants.addRaphconRoute, isNotEmpty);
      expect(AppConstants.adminRoute, isNotEmpty);
    });

    test('route paths start with slash', () {
      expect(AppConstants.homeRoute, startsWith('/'));
      expect(AppConstants.authRoute, startsWith('/'));
      expect(AppConstants.usersRoute, startsWith('/'));
      expect(AppConstants.adminRoute, startsWith('/'));
    });
  });
}
