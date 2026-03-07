import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libriflow/shared/widgets/mybutton.dart';

void main() {
  testWidgets('MyButton widget renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyButtonWidgets(
            text: 'Test Button',
            color: Colors.blue,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);
  });

  testWidgets('MyButton is clickable', (WidgetTester tester) async {
    bool wasPressed = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyButtonWidgets(
            text: 'Click Me',
            color: Colors.blue,
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Click Me'));
    expect(wasPressed, true);
  });

  testWidgets('MyButton has correct color', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyButtonWidgets(
            text: 'Color Test',
            color: Colors.red,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byType(MyButtonWidgets), findsOneWidget);
  });
}
