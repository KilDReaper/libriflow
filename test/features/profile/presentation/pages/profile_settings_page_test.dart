import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libriflow/features/profile/presentation/bloc/profile_event.dart';
import 'package:libriflow/features/profile/presentation/bloc/profile_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libriflow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:libriflow/features/profile/presentation/pages/profile_settings_page.dart';

class MockProfileBloc extends Mock implements ProfileBloc {}
class ProfileStateFake extends Fake implements ProfileState {}
class ProfileEventFake extends Fake implements ProfileEvent {}

void main() {
  late MockProfileBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(ProfileStateFake());
    registerFallbackValue(ProfileEventFake());
  });

  setUp(() {
    mockBloc = MockProfileBloc();
    when(() => mockBloc.state).thenReturn(ProfileInitial());
    // finite stream avoids pumpAndSettle timeout
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(ProfileInitial()));
  });

  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<ProfileBloc>.value(
        value: mockBloc,
        child: child,
      ),
    );
  }

  testWidgets('ProfileSettingsPage renders', (tester) async {
    await tester.pumpWidget(makeTestableWidget(const ProfileSettingsPage()));
    // just pump once, don't pumpAndSettle
    await tester.pump();

    expect(find.byType(ProfileSettingsPage), findsOneWidget);
  });

  testWidgets('Scaffold is present', (tester) async {
    await tester.pumpWidget(makeTestableWidget(const ProfileSettingsPage()));
    await tester.pump();

    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('AppBar is present', (tester) async {
    await tester.pumpWidget(makeTestableWidget(const ProfileSettingsPage()));
    await tester.pump();

    expect(find.byType(AppBar), findsOneWidget);
  });
}
