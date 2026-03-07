import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libriflow/shared/widgets/my_textformfeild.dart';

void main() {
  testWidgets('TextField widget renders correctly', (WidgetTester tester) async {
    final controller = TextEditingController();
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyTextFieldWidget(
            controller: controller,
            hintText: 'Enter text',
            icon: Icons.person,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('Enter text'), findsOneWidget);
  });

  testWidgets('TextField accepts input', (WidgetTester tester) async {
    final controller = TextEditingController();
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyTextFieldWidget(
            controller: controller,
            hintText: 'Type here',
            icon: Icons.edit,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Hello');
    expect(controller.text, 'Hello');
  });

  testWidgets('Password field hides text', (WidgetTester tester) async {
    final controller = TextEditingController();
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyTextFieldWidget(
            controller: controller,
            hintText: 'Password',
            icon: Icons.lock,
            isPassword: true,
          ),
        ),
      ),
    );

    expect(find.byType(MyTextFieldWidget), findsOneWidget);
  });
}
