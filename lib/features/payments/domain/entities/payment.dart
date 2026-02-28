class Payment {
  final String id;
  final String userId;
  final String borrowingId;
  final double amount;
  final String paymentStatus; // pending, success, failed, cancelled
  final String paymentMethod; // khalti, esewa, stripe, cash
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? paidAt;

  const Payment({
    required this.id,
    required this.userId,
    required this.borrowingId,
    required this.amount,
    required this.paymentStatus,
    required this.paymentMethod,
    this.transactionId,
    required this.createdAt,
    this.paidAt,
  });

  bool get isPaid => paymentStatus == 'success';
  bool get isPending => paymentStatus == 'pending';
  bool get isFailed => paymentStatus == 'failed';
}

class UnpaidFine {
  final String borrowingId;
  final String bookTitle;
  final double fineAmount;
  final DateTime dueDate;
  final int daysOverdue;

  const UnpaidFine({
    required this.borrowingId,
    required this.bookTitle,
    required this.fineAmount,
    required this.dueDate,
    required this.daysOverdue,
  });
}
