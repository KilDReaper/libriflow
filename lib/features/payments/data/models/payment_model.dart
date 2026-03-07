import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.userId,
    required super.borrowingId,
    required super.amount,
    required super.paymentStatus,
    required super.paymentMethod,
    super.transactionId,
    required super.createdAt,
    super.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'] ?? json['created_at'];
    final paidAt = json['paidAt'] ?? json['paid_at'];

    return PaymentModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user'] ?? '').toString(),
      borrowingId: (json['borrowingId'] ?? json['borrowing'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: (json['paymentStatus'] ?? json['status'] ?? 'pending').toString(),
      paymentMethod: (json['paymentMethod'] ?? json['method'] ?? 'cash').toString(),
      transactionId: json['transactionId']?.toString(),
      createdAt: createdAt is String
          ? DateTime.tryParse(createdAt) ?? DateTime.now()
          : createdAt is DateTime
              ? createdAt
              : DateTime.now(),
      paidAt: paidAt is String
          ? DateTime.tryParse(paidAt)
          : paidAt is DateTime
              ? paidAt
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'borrowingId': borrowingId,
      'amount': amount,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
    };
  }
}

class UnpaidFineModel extends UnpaidFine {
  const UnpaidFineModel({
    required super.borrowingId,
    required super.bookTitle,
    required super.fineAmount,
    required super.dueDate,
    required super.daysOverdue,
  });

  factory UnpaidFineModel.fromJson(Map<String, dynamic> json) {
    final dueDate = json['dueDate'] ?? json['due_date'];

    return UnpaidFineModel(
      borrowingId: (json['borrowingId'] ?? json['borrowing'] ?? '').toString(),
      bookTitle: (json['bookTitle'] ?? json['title'] ?? '').toString(),
      fineAmount: (json['fineAmount'] as num?)?.toDouble() ?? 0.0,
      dueDate: dueDate is String
          ? DateTime.tryParse(dueDate) ?? DateTime.now()
          : dueDate is DateTime
              ? dueDate
              : DateTime.now(),
      daysOverdue: (json['daysOverdue'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'borrowingId': borrowingId,
      'bookTitle': bookTitle,
      'fineAmount': fineAmount,
      'dueDate': dueDate.toIso8601String(),
      'daysOverdue': daysOverdue,
    };
  }
}
