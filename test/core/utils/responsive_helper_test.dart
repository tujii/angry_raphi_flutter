import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/core/utils/responsive_helper.dart';

void main() {
  group('ResponsiveHelper', () {
    testWidgets('isMobile returns true for mobile width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isMobile(context), isTrue);
                expect(ResponsiveHelper.isTablet(context), isFalse);
                expect(ResponsiveHelper.isDesktop(context), isFalse);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('isTablet returns true for tablet width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 1000)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isMobile(context), isFalse);
                expect(ResponsiveHelper.isTablet(context), isTrue);
                expect(ResponsiveHelper.isDesktop(context), isFalse);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('isDesktop returns true for desktop width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.isMobile(context), isFalse);
                expect(ResponsiveHelper.isTablet(context), isFalse);
                expect(ResponsiveHelper.isDesktop(context), isTrue);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getGridColumns returns correct values', (tester) async {
      // Mobile
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getGridColumns(context), equals(1));
                return Container();
              },
            ),
          ),
        ),
      );

      // Tablet
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 1000)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getGridColumns(context), equals(2));
                return Container();
              },
            ),
          ),
        ),
      );

      // Desktop
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getGridColumns(context), equals(3));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getTextSizeMultiplier returns correct values', (tester) async {
      // Mobile
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getTextSizeMultiplier(context), equals(1.0));
                return Container();
              },
            ),
          ),
        ),
      );

      // Tablet
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 1000)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getTextSizeMultiplier(context), equals(1.1));
                return Container();
              },
            ),
          ),
        ),
      );

      // Desktop
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getTextSizeMultiplier(context), equals(1.2));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getMaxContentWidth returns correct values', (tester) async {
      // Mobile
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getMaxContentWidth(context), equals(double.infinity));
                return Container();
              },
            ),
          ),
        ),
      );

      // Tablet
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 1000)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getMaxContentWidth(context), equals(800));
                return Container();
              },
            ),
          ),
        ),
      );

      // Desktop
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getMaxContentWidth(context), equals(1200));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getFontSize scales with multiplier', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getFontSize(context), equals(14.0));
                return Container();
              },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getFontSize(context), equals(14.0 * 1.2));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getIconSize scales with multiplier', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getIconSize(context), equals(24.0));
                return Container();
              },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveHelper.getIconSize(context), equals(24.0 * 1.2));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    test('breakpoint constants are defined', () {
      expect(ResponsiveHelper.mobileMaxWidth, equals(600));
      expect(ResponsiveHelper.tabletMaxWidth, equals(1024));
      expect(ResponsiveHelper.desktopMaxWidth, equals(1440));
    });
  });
}
