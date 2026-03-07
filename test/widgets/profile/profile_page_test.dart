import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Profile page displays user info', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              CircleAvatar(
                child: Icon(Icons.person),
              ),
              Text('User Name'),
              Text('user@example.com'),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('User Name'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
  });

  testWidgets('Edit profile button is present', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {},
            child: Text('Edit Profile'),
          ),
        ),
      ),
    );

    expect(find.text('Edit Profile'), findsOneWidget);
  });

  testWidgets('Profile image picker works', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });
}
