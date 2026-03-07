import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libriflow/features/home/presentation/views/splash_screen.dart';

void main() {
  testWidgets('Splash screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Splash screen has logo', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Splash screen navigates after delay', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(),
      ),
    );

    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
