import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/features/authentication/presentation/pages/splash_page.dart';
import 'package:angry_raphi/core/constants/app_constants.dart';

void main() {
  group('SplashPage', () {
    testWidgets('should display app logo image', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display app name', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(),
        ),
      );

      expect(find.text(AppConstants.appName), findsOneWidget);
    });

    testWidgets('should display loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have primary color as background', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppConstants.primaryColor);
    });

    testWidgets('should have centered content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should have rounded image corners', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(),
        ),
      );

      expect(find.byType(ClipRRect), findsOneWidget);
      
      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('should have correct image dimensions', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, 200);
      expect(image.height, 200);
    });

    testWidgets('should have white loading indicator', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      
      expect(
        progressIndicator.valueColor,
        isA<AlwaysStoppedAnimation<Color>>(),
      );
    });
  });
}
