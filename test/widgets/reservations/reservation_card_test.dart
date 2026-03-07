import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Reservation card displays book details', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListTile(
            leading: Icon(Icons.book),
            title: Text('Reserved Book'),
            subtitle: Text('Due: 2024-01-01'),
          ),
        ),
      ),
    );

    expect(find.text('Reserved Book'), findsOneWidget);
    expect(find.text('Due: 2024-01-01'), findsOneWidget);
  });

  testWidgets('Cancel button is present', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {},
            child: Text('Cancel Reservation'),
          ),
        ),
      ),
    );

    expect(find.text('Cancel Reservation'), findsOneWidget);
  });

  testWidgets('Reservation list shows multiple items', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              ListTile(title: Text('Book 1')),
              ListTile(title: Text('Book 2')),
              ListTile(title: Text('Book 3')),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(ListTile), findsNWidgets(3));
  });
}
