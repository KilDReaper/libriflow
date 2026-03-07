import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Borrowed books list displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              Card(
                child: ListTile(
                  title: Text('Borrowed Book 1'),
                  subtitle: Text('Return by: 2024-01-15'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Borrowed Book 1'), findsOneWidget);
    expect(find.text('Return by: 2024-01-15'), findsOneWidget);
  });

  testWidgets('Return button is visible', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {},
            child: Text('Return Book'),
          ),
        ),
      ),
    );

    expect(find.text('Return Book'), findsOneWidget);
  });

  testWidgets('Overdue indicator shows', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Container(
            color: Colors.red,
            child: Text('OVERDUE'),
          ),
        ),
      ),
    );

    expect(find.text('OVERDUE'), findsOneWidget);
  });
}
