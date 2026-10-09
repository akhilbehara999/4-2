import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_app/app.dart';

void main() {
  testWidgets('LOG App UI Shell smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LogApp());
    await tester.pumpAndSettle();

    // Verify Home screen UI
    expect(find.widgetWithText(AppBar, 'LOG'), findsOneWidget);
    expect(find.text('We Listen · Organise · Grow'), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);

    // Tap mic button and verify snackbar
    await tester.tap(find.byIcon(Icons.mic));
    await tester.pump();
    expect(find.text('Listening... coming soon'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Navigate to Udhar tab
    await tester.tap(find.text('Udhar'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Udhar'), findsOneWidget);
    expect(find.text('Udhar (ఉధార్)'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);

    // Navigate to Stock tab
    await tester.tap(find.text('Stock'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Stock'), findsOneWidget);
    expect(find.text('Stock (స్టాక్)'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);

    // Navigate to Dashboard tab
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Dashboard'), findsOneWidget);
    expect(find.text('Dashboard (డాష్‌బోర్డ్)'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);

    // Navigate to Ask tab
    await tester.tap(find.text('Ask'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Ask'), findsOneWidget);
    expect(find.text('Ask (సహాయకుడు)'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);

    // Open Settings from app bar icon
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
    expect(find.text('Settings (సెట్టింగ్స్)'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);

    // Navigate back from Settings
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Ask'), findsOneWidget);
  });
}
