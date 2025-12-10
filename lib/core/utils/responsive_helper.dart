import 'package:flutter/material.dart';

/// Utility class for responsive design helpers
class ResponsiveHelper {
  // Breakpoints
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;
  static const double desktopMaxWidth = 1440;

  /// Check if current screen is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMaxWidth;
  }

  /// Check if current screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width < tabletMaxWidth;
  }

  /// Check if current screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }

  /// Get appropriate grid columns based on screen size
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  /// Get max content width for centering on larger screens
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 800;
    } else {
      return 1200;
    }
  }

  /// Get responsive text size multiplier
  static double getTextSizeMultiplier(BuildContext context) {
    if (isMobile(context)) {
      return 1.0;
    } else if (isTablet(context)) {
      return 1.1;
    } else {
      return 1.2;
    }
  }

  /// Get responsive card elevation
  static double getCardElevation(BuildContext context) {
    if (isMobile(context)) {
      return 2.0;
    } else {
      return 4.0;
    }
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, {double baseSize = 24}) {
    return baseSize * getTextSizeMultiplier(context);
  }

  /// Get responsive font size
  static double getFontSize(BuildContext context, {double baseSize = 14}) {
    return baseSize * getTextSizeMultiplier(context);
  }

  /// Wrap content with max width for desktop
  static Widget wrapWithMaxWidth({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    if (isMobile(context)) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? getMaxContentWidth(context),
        ),
        child: child,
      ),
    );
  }

  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    if (isMobile(context)) {
      return kToolbarHeight;
    } else {
      return kToolbarHeight + 8;
    }
  }

  /// Get responsive drawer width
  static double getDrawerWidth(BuildContext context) {
    if (isMobile(context)) {
      return 280;
    } else {
      return 320;
    }
  }
}
