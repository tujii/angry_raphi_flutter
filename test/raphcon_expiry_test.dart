import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/core/constants/app_constants.dart';

void main() {
  group('Raphcon Expiry Constants', () {
    test('Raphcon expiry is set to 365 days (1 year)', () {
      expect(AppConstants.raphconExpiryDays, 365);
    });

    test('Expiry calculation produces correct date', () {
      final now = DateTime(2024, 12, 12);
      final expiryDate = now.subtract(
        Duration(days: AppConstants.raphconExpiryDays),
      );
      
      expect(expiryDate.year, 2023);
      expect(expiryDate.month, 12);
      expect(expiryDate.day, 12);
    });
  });
}
