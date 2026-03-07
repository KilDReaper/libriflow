import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libriflow/features/home/presentation/views/home_view.dart';

void main() {
  testWidgets('Home page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeView(),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('Bottom navigation bar is present', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeView(),
      ),
    );

    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('Home navigation items are present', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeView(),
      ),
    );

    expect(find.byType(BottomNavigationBarItem), findsWidgets);
  });
}
