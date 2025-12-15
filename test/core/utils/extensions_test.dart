import 'package:angry_raphi/core/utils/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringExtensions', () {
    group('capitalize', () {
      test('capitalizes first letter of lowercase string', () {
        expect('hello'.capitalize, equals('Hello'));
      });

      test('keeps already capitalized string unchanged', () {
        expect('Hello'.capitalize, equals('Hello'));
      });

      test('handles empty string', () {
        expect(''.capitalize, equals(''));
      });

      test('capitalizes single character', () {
        expect('a'.capitalize, equals('A'));
      });

      test('only capitalizes first letter', () {
        expect('hello world'.capitalize, equals('Hello world'));
      });
    });

    group('capitalizeWords', () {
      test('capitalizes each word', () {
        expect('hello world'.capitalizeWords, equals('Hello World'));
      });

      test('handles single word', () {
        expect('hello'.capitalizeWords, equals('Hello'));
      });

      test('handles empty string', () {
        expect(''.capitalizeWords, equals(''));
      });

      test('handles multiple spaces', () {
        expect('hello  world'.capitalizeWords, equals('Hello  World'));
      });

      test('handles already capitalized words', () {
        expect('Hello World'.capitalizeWords, equals('Hello World'));
      });
    });

    group('isValidEmail', () {
      test('returns true for valid emails', () {
        expect('user@example.com'.isValidEmail, isTrue);
        expect('test.user@domain.co.uk'.isValidEmail, isTrue);
        expect('name+tag@example.com'.isValidEmail, isTrue);
      });

      test('returns false for invalid emails', () {
        expect('invalid'.isValidEmail, isFalse);
        expect('user@'.isValidEmail, isFalse);
        expect('@example.com'.isValidEmail, isFalse);
        expect('user @example.com'.isValidEmail, isFalse);
        expect(''.isValidEmail, isFalse);
      });
    });
  });

  group('DateTimeExtensions', () {
    group('timeAgo', () {
      test('returns "Just now" for current time', () {
        final now = DateTime.now();
        expect(now.timeAgo, equals('Just now'));
      });

      test('returns minutes ago', () {
        final time = DateTime.now().subtract(const Duration(minutes: 5));
        expect(time.timeAgo, equals('5 minutes ago'));
      });

      test('returns singular minute', () {
        final time = DateTime.now().subtract(const Duration(minutes: 1));
        expect(time.timeAgo, equals('1 minute ago'));
      });

      test('returns hours ago', () {
        final time = DateTime.now().subtract(const Duration(hours: 3));
        expect(time.timeAgo, equals('3 hours ago'));
      });

      test('returns singular hour', () {
        final time = DateTime.now().subtract(const Duration(hours: 1));
        expect(time.timeAgo, equals('1 hour ago'));
      });

      test('returns days ago', () {
        final time = DateTime.now().subtract(const Duration(days: 5));
        expect(time.timeAgo, equals('5 days ago'));
      });

      test('returns singular day', () {
        final time = DateTime.now().subtract(const Duration(days: 1));
        expect(time.timeAgo, equals('1 day ago'));
      });

      test('returns months ago', () {
        final time = DateTime.now().subtract(const Duration(days: 60));
        expect(time.timeAgo, equals('2 months ago'));
      });

      test('returns singular month', () {
        final time = DateTime.now().subtract(const Duration(days: 35));
        expect(time.timeAgo, equals('1 month ago'));
      });

      test('returns years ago', () {
        final time = DateTime.now().subtract(const Duration(days: 730));
        expect(time.timeAgo, equals('2 years ago'));
      });

      test('returns singular year', () {
        final time = DateTime.now().subtract(const Duration(days: 400));
        expect(time.timeAgo, equals('1 year ago'));
      });
    });

    group('formattedDate', () {
      test('formats date correctly', () {
        final date = DateTime(2024, 3, 5);
        expect(date.formattedDate, equals('05.03.2024'));
      });

      test('pads single digit day and month', () {
        final date = DateTime(2024);
        expect(date.formattedDate, equals('01.01.2024'));
      });

      test('handles double digit day and month', () {
        final date = DateTime(2024, 12, 31);
        expect(date.formattedDate, equals('31.12.2024'));
      });
    });
  });

  group('IntExtensions', () {
    group('formattedCount', () {
      test('returns number as string for small values', () {
        expect(0.formattedCount, equals('0'));
        expect(500.formattedCount, equals('500'));
        expect(999.formattedCount, equals('999'));
      });

      test('formats thousands with K suffix', () {
        expect(1000.formattedCount, equals('1.0K'));
        expect(1500.formattedCount, equals('1.5K'));
        expect(15000.formattedCount, equals('15.0K'));
        expect(999949.formattedCount, equals('999.9K'));
      });

      test('formats millions with M suffix', () {
        expect(1000000.formattedCount, equals('1.0M'));
        expect(2500000.formattedCount, equals('2.5M'));
        expect(15000000.formattedCount, equals('15.0M'));
      });
    });
  });
}
