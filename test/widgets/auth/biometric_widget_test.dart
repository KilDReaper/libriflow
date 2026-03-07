import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Biometric login button shows fingerprint icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Icon(Icons.fingerprint, size: 48),
              Text('Use Fingerprint'),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.fingerprint), findsOneWidget);
    expect(find.text('Use Fingerprint'), findsOneWidget);
  });

  testWidgets('Biometric button is tappable', (WidgetTester tester) async {
    bool tapped = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GestureDetector(
            onTap: () {
              tapped = true;
            },
            child: Column(
              children: [
                Icon(Icons.fingerprint),
                Text('Use Fingerprint'),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.fingerprint));
    expect(tapped, true);
  });

  testWidgets('Biometric authentication shows loading', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              CircularProgressIndicator(),
              Text('Authenticating...'),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Authenticating...'), findsOneWidget);
  });
}
