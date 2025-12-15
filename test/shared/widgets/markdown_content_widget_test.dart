import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/shared/widgets/markdown_content_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest({required String content}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
      ],
      home: Scaffold(
        body: SingleChildScrollView(
          child: MarkdownContentWidget(content: content),
        ),
      ),
    );
  }

  group('MarkdownContentWidget', () {
    testWidgets('should display default message when content is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(content: ''));
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should render headers correctly',
        (WidgetTester tester) async {
      const content = '## Header Text\nSome content';

      await tester.pumpWidget(createWidgetUnderTest(content: content));
      await tester.pumpAndSettle();

      expect(find.text('Header Text'), findsOneWidget);
    });

    testWidgets('should render bold text correctly',
        (WidgetTester tester) async {
      const content = '**Bold Text**';

      await tester.pumpWidget(createWidgetUnderTest(content: content));
      await tester.pumpAndSettle();

      expect(find.text('Bold Text'), findsOneWidget);
    });

    testWidgets('should render list items correctly',
        (WidgetTester tester) async {
      const content = '- Item 1\n- Item 2\n- Item 3';

      await tester.pumpWidget(createWidgetUnderTest(content: content));
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('should render regular text correctly',
        (WidgetTester tester) async {
      const content = 'Regular text content';

      await tester.pumpWidget(createWidgetUnderTest(content: content));
      await tester.pumpAndSettle();

      expect(find.text('Regular text content'), findsOneWidget);
    });

    testWidgets('should skip empty lines', (WidgetTester tester) async {
      const content = 'Line 1\n\n\nLine 2';

      await tester.pumpWidget(createWidgetUnderTest(content: content));
      await tester.pumpAndSettle();

      expect(find.text('Line 1'), findsOneWidget);
      expect(find.text('Line 2'), findsOneWidget);
    });

    testWidgets('should render mixed content correctly',
        (WidgetTester tester) async {
      const content = '''
## Header
**Bold Section**
- List item 1
- List item 2
Regular text
''';

      await tester.pumpWidget(createWidgetUnderTest(content: content));
      await tester.pumpAndSettle();

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Bold Section'), findsOneWidget);
      expect(find.text('List item 1'), findsOneWidget);
      expect(find.text('List item 2'), findsOneWidget);
      expect(find.text('Regular text'), findsOneWidget);
    });

    testWidgets('should use Column for layout', (WidgetTester tester) async {
      const content = '## Test\nContent';

      await tester.pumpWidget(createWidgetUnderTest(content: content));
      await tester.pumpAndSettle();

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should handle list items with emojis',
        (WidgetTester tester) async {
      const content = '- 🎯 Item with emoji';

      await tester.pumpWidget(createWidgetUnderTest(content: content));
      await tester.pumpAndSettle();

      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('should render multiple headers', (WidgetTester tester) async {
      const content = '## Header 1\n## Header 2\n## Header 3';

      await tester.pumpWidget(createWidgetUnderTest(content: content));
      await tester.pumpAndSettle();

      expect(find.text('Header 1'), findsOneWidget);
      expect(find.text('Header 2'), findsOneWidget);
      expect(find.text('Header 3'), findsOneWidget);
    });
  });
}
