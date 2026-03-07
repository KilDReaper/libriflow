import '../../domain/entities/reservation.dart';

class ReservationModel extends Reservation {
  const ReservationModel({
    required super.id,
    required super.bookId,
    required super.bookTitle,
    required super.status,
    required super.queuePosition,
    required super.expiresAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final expires = json['expiresAt'] ?? json['expiryAt'] ?? json['expiry'];
    final expiresAt = expires is String
        ? DateTime.tryParse(expires)
        : expires is DateTime
            ? expires
            : null;

    return ReservationModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      bookId: (json['bookId'] ?? '').toString(),
      bookTitle: (json['bookTitle'] ?? json['title'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      queuePosition: (json['queuePosition'] as num?)?.toInt() ?? 0,
      expiresAt: expiresAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'status': status,
      'queuePosition': queuePosition,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}
