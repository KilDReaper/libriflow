import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Notification icon shows badge', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Icon(Icons.notifications),
              Positioned(
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text('3', style: TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('Filter chips are displayed', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              Chip(label: Text('Fiction')),
              Chip(label: Text('Non-Fiction')),
              Chip(label: Text('Science')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Fiction'), findsOneWidget);
    expect(find.text('Non-Fiction'), findsOneWidget);
    expect(find.text('Science'), findsOneWidget);
  });

  testWidgets('Book rating stars are shown', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < 4 ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.star), findsNWidgets(4));
    expect(find.byIcon(Icons.star_border), findsOneWidget);
  });
}
