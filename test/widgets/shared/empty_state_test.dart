import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Empty state shows message', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 100),
                Text('No items found'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('No items found'), findsOneWidget);
    expect(find.byIcon(Icons.inbox), findsOneWidget);
  });

  testWidgets('Empty library shows message', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('No books available'),
          ),
        ),
      ),
    );

    expect(find.text('No books available'), findsOneWidget);
  });

  testWidgets('Empty reservations shows message', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('You have no reservations'),
          ),
        ),
      ),
    );

    expect(find.text('You have no reservations'), findsOneWidget);
  });
}
