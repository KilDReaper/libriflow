import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Loading indicator shows correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Error message displays', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error: Could not load data'),
          ),
        ),
      ),
    );

    expect(find.text('Error: Could not load data'), findsOneWidget);
  });

  testWidgets('Retry button appears on error', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('Error occurred'),
              ElevatedButton(
                onPressed: () {},
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Retry'), findsOneWidget);
  });
}
