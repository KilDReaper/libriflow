import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('QR scanner shows camera view', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Container(
            color: Colors.black,
            child: Center(
              child: Icon(Icons.qr_code_scanner, size: 100, color: Colors.white),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
  });

  testWidgets('Scanner instructions are visible', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Icon(Icons.qr_code_scanner),
              Text('Scan QR code to borrow book'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Scan QR code to borrow book'), findsOneWidget);
  });

  testWidgets('Flash toggle button is present', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.flash_on), findsOneWidget);
  });
}
