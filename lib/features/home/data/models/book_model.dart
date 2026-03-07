class BookModel {
  final String id;
  final String title;
  final String author;
  final int price;
  final String image;
  final String section;
  final double rating;
  final String transactionType; // 'rented' or 'purchased'
  final DateTime transactionDate;
  final int? rentalDays; // null for purchased books

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.image,
    required this.section,
    required this.rating,
    required this.transactionType,
    required this.transactionDate,
    this.rentalDays,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'price': price,
      'image': image,
      'section': section,
      'rating': rating,
      'transactionType': transactionType,
      'transactionDate': transactionDate.toIso8601String(),
      'rentalDays': rentalDays,
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      price: map['price'] as int,
      image: map['image'] as String,
      section: map['section'] as String,
      rating: (map['rating'] as num).toDouble(),
      transactionType: map['transactionType'] as String,
      transactionDate: DateTime.parse(map['transactionDate'] as String),
      rentalDays: map['rentalDays'] as int?,
    );
  }

  int get daysLeft {
    if (transactionType != 'rented' || rentalDays == null) return 0;
    final expiryDate = transactionDate.add(Duration(days: rentalDays!));
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }
}
