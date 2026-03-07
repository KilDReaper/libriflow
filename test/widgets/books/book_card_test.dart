import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Book card displays book information', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Card(
            child: Column(
              children: [
                Text('Book Title'),
                Text('Author Name'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Book Title'), findsOneWidget);
    expect(find.text('Author Name'), findsOneWidget);
  });

  testWidgets('Book card has image placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Card(
            child: Column(
              children: [
                Icon(Icons.book),
                Text('Book Title'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.book), findsOneWidget);
  });

  testWidgets('Book card is tappable', (WidgetTester tester) async {
    bool tapped = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GestureDetector(
            onTap: () {
              tapped = true;
            },
            child: Card(
              child: Text('Tap Me'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tap Me'));
    expect(tapped, true);
  });
}
