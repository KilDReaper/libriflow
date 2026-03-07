import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libriflow/features/auth/presentation/views/signup_page.dart';

void main() {
  testWidgets('Signup page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignupView(),
      ),
    );

    expect(find.text('Sign Up'), findsWidgets);
  });

  testWidgets('All signup fields are present', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignupView(),
      ),
    );

    expect(find.byType(TextFormField), findsWidgets);
  });

  testWidgets('Signup button is present', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignupView(),
      ),
    );

    expect(find.text('Sign Up'), findsWidgets);
  });
}
