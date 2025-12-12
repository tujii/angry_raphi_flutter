import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:angry_raphi/shared/widgets/confirmation_dialog.dart';

void main() {
  group('ConfirmationDialog', () {
    testWidgets('should display title and message', (WidgetTester tester) async {
      const testTitle = 'Delete Item';
      const testMessage = 'Are you sure you want to delete this item?';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmationDialog(
              title: testTitle,
              message: testMessage,
              onConfirm: () {},
            ),
          ),
        ),
      );

      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('should display default button texts', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmationDialog(
              title: 'Test',
              message: 'Test message',
              onConfirm: () {},
            ),
          ),
        ),
      );

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should display custom button texts when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmationDialog(
              title: 'Test',
              message: 'Test message',
              onConfirm: () {},
              confirmText: 'Delete',
              cancelText: 'Go Back',
            ),
          ),
        ),
      );

      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
    });

    testWidgets('should call onConfirm when confirm button is tapped',
        (WidgetTester tester) async {
      bool confirmCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmationDialog(
              title: 'Test',
              message: 'Test message',
              onConfirm: () => confirmCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(confirmCalled, true);
    });

    testWidgets('should call custom onCancel when cancel button is tapped',
        (WidgetTester tester) async {
      bool cancelCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmationDialog(
              title: 'Test',
              message: 'Test message',
              onConfirm: () {},
              onCancel: () => cancelCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(cancelCalled, true);
    });

    testWidgets('should have TextButton for cancel and ElevatedButton for confirm',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmationDialog(
              title: 'Test',
              message: 'Test message',
              onConfirm: () {},
            ),
          ),
        ),
      );

      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('show static method should display dialog',
        (WidgetTester tester) async {
      bool confirmCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ConfirmationDialog.show(
                      context: context,
                      title: 'Test Title',
                      message: 'Test Message',
                      onConfirm: () => confirmCalled = true,
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);

      // Tap confirm
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(confirmCalled, true);
    });

    testWidgets('show static method should use custom button texts',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ConfirmationDialog.show(
                      context: context,
                      title: 'Test',
                      message: 'Test',
                      onConfirm: () {},
                      confirmText: 'Yes',
                      cancelText: 'No',
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });
  });
}
