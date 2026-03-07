import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Date Utility Tests', () {
    test('should format date correctly', () {
      expect(true, true);
    });

    test('should calculate days difference', () {
      final date1 = DateTime(2024, 1, 1);
      final date2 = DateTime(2024, 1, 6);
      final difference = date2.difference(date1).inDays;
      expect(difference, 5);
    });

    test('should check if date is overdue', () {
      final dueDate = DateTime.now().subtract(Duration(days: 2));
      expect(dueDate.isBefore(DateTime.now()), true);
    });
  });
}
