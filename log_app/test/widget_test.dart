import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:log_app/app.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('First-time Setup onboarding full flow test', (WidgetTester tester) async {
    await tester.pumpWidget(const LogApp());
    await tester.pumpAndSettle();

    // Step 1: Welcome & Language
    expect(find.text('LOG'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('తెలుగు + English'), findsOneWidget);

    // Tap Next to Step 2
    await tester.tap(find.text('Next · తరువాత'));
    await tester.pumpAndSettle();

    // Step 2: Shop details
    expect(find.text('Your shop'), findsOneWidget);
    expect(find.text('Sri Lakshmi Kirana'), findsWidgets);

    // Tap Next to Step 3
    await tester.tap(find.text('Next · తరువాత'));
    await tester.pumpAndSettle();

    // Step 3: Microphone permission & test
    expect(find.text('Let LOG hear you'), findsOneWidget);
    expect(find.text('Allow microphone'), findsOneWidget);

    // Tap Allow microphone
    await tester.tap(find.text('Allow microphone'));
    await tester.pumpAndSettle();
    expect(find.text('Microphone is on'), findsOneWidget);

    // Tap Next to Step 4
    await tester.tap(find.text('Next · తరువాత'));
    await tester.pumpAndSettle();

    // Step 4: You are ready
    expect(find.text('You are ready'), findsOneWidget);
    expect(find.text('Weekly stock check'), findsOneWidget);
    expect(find.text('Start using LOG · ప్రారంభించండి'), findsOneWidget);

    // Complete setup: Tap Start using LOG
    await tester.tap(find.text('Start using LOG · ప్రారంభించండి'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify Home screen reached
    expect(find.text('LOG'), findsOneWidget);
    expect(find.text("Today's business"), findsOneWidget);
    expect(find.text('WEEKLY REVENUE'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);

    // Tap More tab in bottom bar
    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify More screen 2x2 tonal hub tiles & quick tools
    expect(find.text('More'), findsOneWidget);
    expect(find.text('మరిన్ని'), findsOneWidget);
    expect(find.text('Udhar'), findsOneWidget);
    expect(find.text('Stock'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Ask'), findsOneWidget);
    expect(find.text('All Transactions'), findsOneWidget);
    expect(find.text('Customers'), findsOneWidget);
  });
}
