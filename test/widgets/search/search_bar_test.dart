import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Search bar renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextField(
            decoration: InputDecoration(
              hintText: 'Search books...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.text('Search books...'), findsOneWidget);
  });

  testWidgets('Search bar accepts input', (WidgetTester tester) async {
    final controller = TextEditingController();
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Search'),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Harry Potter');
    expect(controller.text, 'Harry Potter');
  });

  testWidgets('Search icon is visible', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.search), findsOneWidget);
  });
}
