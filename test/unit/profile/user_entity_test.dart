import 'package:flutter_test/flutter_test.dart';
import 'package:libriflow/features/profile/domain/entities/user.dart';

void main() {
  test('User entity stores base fields', () {
    const user = User(
      id: 'u1',
      name: 'Aayam',
      email: 'aayam@example.com',
      phoneNumber: '+1234567890',
      avatarUrl: 'https://example.com/avatar.jpg',
    );

    expect(user.id, 'u1');
    expect(user.name, 'Aayam');
    expect(user.email, 'aayam@example.com');
    expect(user.phoneNumber, '+1234567890');
    expect(user.avatarUrl, 'https://example.com/avatar.jpg');
  });

  test('User profilePictureUrl getter currently returns null', () {
    const user = User(
      id: 'u2',
      name: 'User',
      email: 'user@example.com',
      phoneNumber: '+1000000000',
    );

    expect(user.profilePictureUrl, isNull);
  });
}
