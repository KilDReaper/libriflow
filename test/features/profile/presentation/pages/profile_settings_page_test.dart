import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:libriflow/features/profile/presentation/pages/profile_settings_page.dart';
import 'package:libriflow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:libriflow/features/profile/presentation/bloc/profile_state.dart';
import 'package:libriflow/features/profile/presentation/bloc/profile_event.dart';
import 'package:libriflow/features/profile/domain/entities/user.dart';

class MockProfileBloc extends Mock implements ProfileBloc {}

class FakeProfileEvent extends Fake implements ProfileEvent {}

class FakeProfileState extends Fake implements ProfileState {}

void main() {
  late ProfileBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakeProfileEvent());
    registerFallbackValue(FakeProfileState());
  });

  setUp(() {
    mockBloc = MockProfileBloc();
  });

  final testUser = User(
    id: "1",
    name: "John",
    email: "john@test.com",
    avatarUrl: "http://example.com/avatar.jpg",
    phoneNumber: "1234567890",
  );

  testWidgets('ProfileSettingsPage renders without crashing', (tester) async {
    when(() => mockBloc.state).thenReturn(ProfileLoaded(testUser));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProfileBloc>.value(
          value: mockBloc,
          child: const ProfileSettingsPage(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(ProfileSettingsPage), findsOneWidget);
  });

  testWidgets('ProfileSettingsPage contains Scaffold', (tester) async {
    when(() => mockBloc.state).thenReturn(ProfileLoaded(testUser));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProfileBloc>.value(
          value: mockBloc,
          child: const ProfileSettingsPage(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('ProfileSettingsPage displays AppBar', (tester) async {
    when(() => mockBloc.state).thenReturn(ProfileLoaded(testUser));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProfileBloc>.value(
          value: mockBloc,
          child: const ProfileSettingsPage(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('ProfileSettingsPage displays text fields', (tester) async {
    when(() => mockBloc.state).thenReturn(ProfileLoaded(testUser));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProfileBloc>.value(
          value: mockBloc,
          child: const ProfileSettingsPage(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(TextFormField), findsNWidgets(4)); // name, email, password, confirm
  });

  testWidgets('ProfileSettingsPage displays profile image', (tester) async {
    when(() => mockBloc.state).thenReturn(ProfileLoaded(testUser));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProfileBloc>.value(
          value: mockBloc,
          child: const ProfileSettingsPage(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(CircleAvatar), findsOneWidget);
  });
}
