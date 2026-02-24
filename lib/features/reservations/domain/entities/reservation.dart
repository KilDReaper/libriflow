class Reservation {
  final String id;
  final String bookId;
  final String bookTitle;
  final String status;
  final int queuePosition;
  final DateTime expiresAt;

  const Reservation({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.status,
    required this.queuePosition,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
