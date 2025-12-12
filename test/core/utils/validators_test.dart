import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('should return null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
        expect(Validators.validateEmail('user.name@domain.co.uk'), isNull);
        expect(Validators.validateEmail('john_doe@company.org'), isNull);
      });

      test('should return error message for empty email', () {
        expect(Validators.validateEmail(''), equals('Email is required'));
        expect(Validators.validateEmail(null), equals('Email is required'));
      });

      test('should return error message for invalid email format', () {
        expect(
          Validators.validateEmail('invalid'),
          equals('Please enter a valid email'),
        );
        expect(
          Validators.validateEmail('test@'),
          equals('Please enter a valid email'),
        );
        expect(
          Validators.validateEmail('@example.com'),
          equals('Please enter a valid email'),
        );
        expect(
          Validators.validateEmail('test@.com'),
          equals('Please enter a valid email'),
        );
      });
    });

    group('validateName', () {
      test('should return null for valid name', () {
        expect(Validators.validateName('John'), isNull);
        expect(Validators.validateName('Jane Doe'), isNull);
        expect(Validators.validateName('A' * 50), isNull); // Max length
      });

      test('should return error message for empty name', () {
        expect(Validators.validateName(''), equals('Name is required'));
        expect(Validators.validateName(null), equals('Name is required'));
      });

      test('should return error message for name too short', () {
        expect(
          Validators.validateName('A'),
          equals('Name must be at least 2 characters'),
        );
      });

      test('should return error message for name too long', () {
        expect(
          Validators.validateName('A' * 51),
          equals('Name cannot exceed 50 characters'),
        );
      });
    });

    group('validateDescription', () {
      test('should return null for valid description', () {
        expect(Validators.validateDescription('Short description'), isNull);
        expect(Validators.validateDescription(''), isNull);
        expect(Validators.validateDescription(null), isNull);
        expect(Validators.validateDescription('A' * 500), isNull); // Max length
      });

      test('should return error message for description too long', () {
        expect(
          Validators.validateDescription('A' * 501),
          equals('Description cannot exceed 500 characters'),
        );
      });
    });

    group('validateRequired', () {
      test('should return null for non-empty value', () {
        expect(Validators.validateRequired('Some value', 'Field'), isNull);
        expect(Validators.validateRequired('123', 'Number'), isNull);
      });

      test('should return error message with field name for empty value', () {
        expect(
          Validators.validateRequired('', 'Username'),
          equals('Username is required'),
        );
        expect(
          Validators.validateRequired(null, 'Password'),
          equals('Password is required'),
        );
      });
    });

    group('isValidImageType', () {
      test('should return true for valid image extensions', () {
        expect(Validators.isValidImageType('photo.jpg'), isTrue);
        expect(Validators.isValidImageType('image.jpeg'), isTrue);
        expect(Validators.isValidImageType('picture.png'), isTrue);
        expect(Validators.isValidImageType('graphic.webp'), isTrue);
      });

      test('should return true for valid extensions regardless of case', () {
        expect(Validators.isValidImageType('photo.JPG'), isTrue);
        expect(Validators.isValidImageType('image.JPEG'), isTrue);
        expect(Validators.isValidImageType('picture.PNG'), isTrue);
        expect(Validators.isValidImageType('graphic.WEBP'), isTrue);
      });

      test('should return false for invalid image extensions', () {
        expect(Validators.isValidImageType('document.pdf'), isFalse);
        expect(Validators.isValidImageType('video.mp4'), isFalse);
        expect(Validators.isValidImageType('file.txt'), isFalse);
        expect(Validators.isValidImageType('archive.zip'), isFalse);
      });

      test('should return false for files without extension', () {
        expect(Validators.isValidImageType('filename'), isFalse);
      });
    });

    group('isValidImageSize', () {
      test('should return true for valid image sizes', () {
        expect(Validators.isValidImageSize(1024), isTrue); // 1KB
        expect(Validators.isValidImageSize(1024 * 1024), isTrue); // 1MB
        expect(Validators.isValidImageSize(5 * 1024 * 1024), isTrue); // 5MB (max)
      });

      test('should return false for image sizes exceeding limit', () {
        expect(
          Validators.isValidImageSize(5 * 1024 * 1024 + 1),
          isFalse,
        ); // 5MB + 1 byte
        expect(
          Validators.isValidImageSize(10 * 1024 * 1024),
          isFalse,
        ); // 10MB
      });

      test('should return true for zero size', () {
        expect(Validators.isValidImageSize(0), isTrue);
      });
    });
  });
}
