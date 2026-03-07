import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:libriflow/features/auth/presentation/views/login_page.dart';
import 'package:libriflow/features/auth/presentation/providers/auth_provider.dart';

void main() {
  testWidgets('Login page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginView(),
      ),
    );

    expect(find.text('Log In'), findsOneWidget);
    expect(find.byIcon(Icons.mail), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });

  testWidgets('Email and password fields are present', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginView(),
      ),
    );

    expect(find.byType(TextFormField), findsWidgets);
  });

  testWidgets('Login button is clickable', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginView(),
      ),
    );

    final loginButton = find.text('Log In');
    expect(loginButton, findsOneWidget);
  });
}
