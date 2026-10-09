import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_app/app.dart';
import 'package:log_app/core/strings.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite_dev.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    databaseFactory = sqfliteDatabaseFactoryDefault;
    const channel = MethodChannel('com.tekartik.sqflite');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'getDatabasesPath':
          return '/data/data/com.log.log_app/databases';
        case 'openDatabase':
          return 1;
        case 'execute':
          return null;
        case 'insert':
          return 1;
        case 'update':
          return 1;
        case 'query':
          return [];
        case 'rawQuery':
          return [
            {'COUNT(*)': 8}
          ];
        case 'batch':
          return [];
        case 'closeDatabase':
          return null;
        default:
          return null;
      }
    });
  });

  testWidgets('LOG App UI Shell smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LogApp());
    await tester.pumpAndSettle();

    // Verify Home screen UI
    expect(find.widgetWithText(AppBar, 'LOG'), findsOneWidget);
    expect(find.text('We Listen · Organise · Grow'), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);
    expect(find.text('Type instead (e.g. Ramesh ki 5 kg biyyam udhar 300 rs)'), findsOneWidget);

    // Navigate to Udhar tab
    await tester.tap(find.text('Udhar'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Udhar'), findsOneWidget);
    expect(find.text('Total Udhar (మొత్తం బాకీ)'), findsOneWidget);

    // Navigate to Stock tab
    await tester.tap(find.text('Stock'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Stock'), findsOneWidget);
    expect(find.text('Inventory Stock (సరుకుల నిల్వ)'), findsOneWidget);

    // Navigate to Dashboard tab
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Dashboard'), findsOneWidget);
    expect(find.text('7 రోజులు · 7 Days'), findsOneWidget);

    // Navigate to Ask tab
    await tester.tap(find.text('Ask'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Ask'), findsOneWidget);
    expect(find.text('Ask (సహాయకుడు)'), findsOneWidget);

    // Open Settings from app bar icon
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, AppStrings.settings), findsOneWidget);

    // Navigate back from Settings
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Ask'), findsOneWidget);
  });

  testWidgets('Type sentence -> Confirm screen -> Save flow', (WidgetTester tester) async {
    await tester.pumpWidget(const LogApp());
    await tester.pumpAndSettle();

    // Type a sentence on Home screen
    final inputField = find.byType(TextField);
    expect(inputField, findsOneWidget);
    await tester.enterText(inputField, 'Ramesh ki 5 kilo biyyam udhar 300 rs');
    await tester.tap(find.text('Parse'));
    await tester.pumpAndSettle();

    // ConfirmScreen opened
    expect(find.text('Confirm Entry (ఖరారు చేయండి)'), findsOneWidget);
    expect(find.text('Save (సేవ్)'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Scroll and tap Cancel
    await tester.ensureVisible(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm Entry (ఖరారు చేయండి)'), findsNothing);
  });
}
