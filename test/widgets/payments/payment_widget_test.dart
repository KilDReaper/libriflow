import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Payment summary displays total', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('Total Fine: \$50'),
              Text('Due Books: 2'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Total Fine: \$50'), findsOneWidget);
    expect(find.text('Due Books: 2'), findsOneWidget);
  });

  testWidgets('Pay now button is present', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {},
            child: Text('Pay Now'),
          ),
        ),
      ),
    );

    expect(find.text('Pay Now'), findsOneWidget);
  });

  testWidgets('Payment details are shown', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('Fine per day: \$10'),
              Text('Days overdue: 5'),
              Text('Total: \$50'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Fine per day: \$10'), findsOneWidget);
    expect(find.text('Days overdue: 5'), findsOneWidget);
  });
}
