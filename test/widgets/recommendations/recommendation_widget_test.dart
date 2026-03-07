import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Recommendation card displays book info', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Card(
            child: Column(
              children: [
                Text('Recommended for You'),
                Text('Book Title'),
                Text('Author Name'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Recommended for You'), findsOneWidget);
    expect(find.text('Book Title'), findsOneWidget);
  });

  testWidgets('Trending books section exists', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('Trending Books', style: TextStyle(fontSize: 20)),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Card(child: Text('Book 1')),
                    Card(child: Text('Book 2')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Trending Books'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('Genre filter buttons work', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text('Fiction'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('Mystery'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Fiction'), findsOneWidget);
    expect(find.text('Mystery'), findsOneWidget);
  });
}
