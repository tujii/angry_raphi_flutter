/// Extension methods for String manipulation and validation.
extension StringExtensions on String {
  /// Capitalizes the first character of the string.
  ///
  /// Returns the string with the first character in uppercase and
  /// the rest unchanged. Returns the original string if empty.
  ///
  /// Example:
  /// ```dart
  /// final text = 'hello'.capitalize;
  /// print(text); // 'Hello'
  /// ```
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Capitalizes the first character of each word in the string.
  ///
  /// Splits the string by spaces and capitalizes each word individually.
  /// Returns the original string if empty.
  ///
  /// Example:
  /// ```dart
  /// final text = 'hello world'.capitalizeWords;
  /// print(text); // 'Hello World'
  /// ```
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Checks if the string is a valid email address.
  ///
  /// Uses a regular expression to validate email format.
  /// Returns `true` if the string matches the email pattern.
  ///
  /// Example:
  /// ```dart
  /// final isValid = 'user@example.com'.isValidEmail;
  /// print(isValid); // true
  /// ```
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
    );
    return emailRegex.hasMatch(this);
  }
}

/// Extension methods for DateTime formatting and manipulation.
extension DateTimeExtensions on DateTime {
  /// Converts the DateTime to a human-readable "time ago" string.
  ///
  /// Returns a relative time description (e.g., "2 hours ago", "3 days ago")
  /// based on the difference between this DateTime and the current time.
  ///
  /// Time ranges:
  /// - Years: More than 365 days
  /// - Months: More than 30 days
  /// - Days: More than 0 days
  /// - Hours: More than 0 hours
  /// - Minutes: More than 0 minutes
  /// - Otherwise: "Just now"
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime.now().subtract(Duration(hours: 2));
  /// print(date.timeAgo); // '2 hours ago'
  /// ```
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Formats the DateTime as a European date string (DD.MM.YYYY).
  ///
  /// Returns the date in the format "DD.MM.YYYY" with leading zeros.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 3, 5);
  /// print(date.formattedDate); // '05.03.2024'
  /// ```
  String get formattedDate {
    return '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year';
  }
}

/// Extension methods for integer formatting and display.
extension IntExtensions on int {
  /// Formats large numbers with K (thousands) or M (millions) suffix.
  ///
  /// Returns a formatted string with one decimal place for values
  /// 1000 or greater, using 'K' for thousands and 'M' for millions.
  ///
  /// Examples:
  /// ```dart
  /// print(500.formattedCount);        // '500'
  /// print(1500.formattedCount);       // '1.5K'
  /// print(2500000.formattedCount);    // '2.5M'
  /// ```
  String get formattedCount {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    }
    if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}
