import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App bar displays title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('LibriFlow'),
          ),
        ),
      ),
    );

    expect(find.text('LibriFlow'), findsOneWidget);
  });

  testWidgets('App bar has menu icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            leading: Icon(Icons.menu),
            title: Text('Home'),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  testWidgets('App bar has action buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Books'),
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
  });
}
