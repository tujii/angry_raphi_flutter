import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/core/utils/validators.dart';

void main() {
  group('Validators.validateEmail', () {
    test('returns null for valid email', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(Validators.validateEmail('test.user@domain.co.uk'), isNull);
      expect(Validators.validateEmail('name+tag@example.com'), isNull);
    });

    test('returns error for null email', () {
      expect(Validators.validateEmail(null), equals('Email is required'));
    });

    test('returns error for empty email', () {
      expect(Validators.validateEmail(''), equals('Email is required'));
    });

    test('returns error for invalid email format', () {
      expect(Validators.validateEmail('invalid'), equals('Please enter a valid email'));
      expect(Validators.validateEmail('user@'), equals('Please enter a valid email'));
      expect(Validators.validateEmail('@example.com'), equals('Please enter a valid email'));
      expect(Validators.validateEmail('user @example.com'), equals('Please enter a valid email'));
    });
  });

  group('Validators.validateName', () {
    test('returns null for valid name', () {
      expect(Validators.validateName('John'), isNull);
      expect(Validators.validateName('Jane Doe'), isNull);
      expect(Validators.validateName('A' * 50), isNull);
    });

    test('returns error for null name', () {
      expect(Validators.validateName(null), equals('Name is required'));
    });

    test('returns error for empty name', () {
      expect(Validators.validateName(''), equals('Name is required'));
    });

    test('returns error for name too short', () {
      expect(Validators.validateName('A'), equals('Name must be at least 2 characters'));
    });

    test('returns error for name too long', () {
      expect(Validators.validateName('A' * 51), equals('Name cannot exceed 50 characters'));
    });
  });

  group('Validators.validateDescription', () {
    test('returns null for valid description', () {
      expect(Validators.validateDescription('Valid description'), isNull);
      expect(Validators.validateDescription('A' * 500), isNull);
    });

    test('returns null for null description', () {
      expect(Validators.validateDescription(null), isNull);
    });

    test('returns null for empty description', () {
      expect(Validators.validateDescription(''), isNull);
    });

    test('returns error for description too long', () {
      expect(
        Validators.validateDescription('A' * 501),
        equals('Description cannot exceed 500 characters'),
      );
    });
  });

  group('Validators.validateRequired', () {
    test('returns null for valid value', () {
      expect(Validators.validateRequired('value', 'Field'), isNull);
      expect(Validators.validateRequired('x', 'Test'), isNull);
    });

    test('returns error with field name for null value', () {
      expect(Validators.validateRequired(null, 'Username'), equals('Username is required'));
    });

    test('returns error with field name for empty value', () {
      expect(Validators.validateRequired('', 'Password'), equals('Password is required'));
    });
  });

  group('Validators.isValidImageType', () {
    test('returns true for valid image types', () {
      expect(Validators.isValidImageType('photo.jpg'), isTrue);
      expect(Validators.isValidImageType('image.jpeg'), isTrue);
      expect(Validators.isValidImageType('pic.png'), isTrue);
      expect(Validators.isValidImageType('graphic.webp'), isTrue);
    });

    test('returns true for uppercase extensions', () {
      expect(Validators.isValidImageType('photo.JPG'), isTrue);
      expect(Validators.isValidImageType('image.PNG'), isTrue);
    });

    test('returns false for invalid image types', () {
      expect(Validators.isValidImageType('document.pdf'), isFalse);
      expect(Validators.isValidImageType('video.mp4'), isFalse);
      expect(Validators.isValidImageType('file.txt'), isFalse);
      expect(Validators.isValidImageType('image.gif'), isFalse);
    });

    test('returns false for files without extension', () {
      expect(Validators.isValidImageType('noextension'), isFalse);
    });
  });

  group('Validators.isValidImageSize', () {
    test('returns true for valid image sizes', () {
      expect(Validators.isValidImageSize(1024), isTrue); // 1 KB
      expect(Validators.isValidImageSize(1024 * 1024), isTrue); // 1 MB
      expect(Validators.isValidImageSize(5 * 1024 * 1024), isTrue); // 5 MB (max)
    });

    test('returns false for image size exceeding limit', () {
      expect(Validators.isValidImageSize(5 * 1024 * 1024 + 1), isFalse);
      expect(Validators.isValidImageSize(10 * 1024 * 1024), isFalse);
    });

    test('returns true for zero size', () {
      expect(Validators.isValidImageSize(0), isTrue);
    });
  });
}
