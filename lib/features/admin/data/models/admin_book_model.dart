class AdminBookModel {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final List<String> genres;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final String? language;
  final int? pages;
  final String image;
  final int price;
  final double rating;
  final int totalReviews;
  final int stockQuantity;
  final int availableQuantity;
  final int borrowedQuantity;
  final String status; // 'available', 'out_of_stock', 'discontinued'
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminBookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.genres,
    this.publisher,
    this.publishedDate,
    this.description,
    this.language,
    this.pages,
    required this.image,
    required this.price,
    required this.rating,
    required this.totalReviews,
    required this.stockQuantity,
    required this.availableQuantity,
    required this.borrowedQuantity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminBookModel.fromJson(Map<String, dynamic> json) {
    // Handle author field (can be string or array)
    final authorValue = json['author'] ?? json['authors'] ?? json['writer'];
    final String author = authorValue is List
        ? (authorValue.isNotEmpty ? authorValue.first.toString() : 'Unknown')
        : (authorValue ?? 'Unknown').toString();

    // Handle genres (can be string or array)
    List<String> genres = [];
    final genreValue = json['genre'] ?? json['genres'] ?? json['category'];
    if (genreValue is List) {
      genres = genreValue.map((e) => e.toString()).toList();
    } else if (genreValue is String && genreValue.isNotEmpty) {
      genres = [genreValue];
    }

    // Handle image/cover field
    final image = (json['image'] ??
            json['coverUrl'] ??
            json['cover'] ??
            json['imageUrl'] ??
            json['coverImage'] ??
            json['thumbnail'] ??
            '')
        .toString();

    // Calculate borrowed quantity
    final stock = (json['stockQuantity'] ?? json['stock'] ?? 0) as num;
    final available =
        (json['availableQuantity'] ?? json['available'] ?? stock) as num;
    final borrowed = stock.toInt() - available.toInt();

    return AdminBookModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['bookTitle'] ?? 'Untitled').toString(),
      author: author,
      isbn: (json['isbn'] ?? json['ISBN'] ?? '').toString(),
      genres: genres,
      publisher: json['publisher']?.toString(),
      publishedDate: json['publishedDate']?.toString(),
      description: json['description']?.toString(),
      language: json['language']?.toString(),
      pages: (json['pages'] ?? json['pageCount']) as int?,
      image: image,
      price: ((json['price'] ?? json['rentalPrice'] ?? 0) as num).toInt(),
      rating: ((json['rating'] ?? json['averageRating'] ?? 0) as num).toDouble(),
      totalReviews: ((json['totalReviews'] ?? json['reviewCount'] ?? 0) as num).toInt(),
      stockQuantity: stock.toInt(),
      availableQuantity: available.toInt(),
      borrowedQuantity: borrowed,
      status: (json['status'] ?? 'available').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'genres': genres,
      'publisher': publisher,
      'publishedDate': publishedDate,
      'description': description,
      'language': language,
      'pages': pages,
      'image': image,
      'price': price,
      'rating': rating,
      'totalReviews': totalReviews,
      'stockQuantity': stockQuantity,
      'availableQuantity': availableQuantity,
      'borrowedQuantity': borrowedQuantity,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isAvailable => status == 'available' && availableQuantity > 0;
  bool get isOutOfStock => availableQuantity == 0;

  AdminBookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    List<String>? genres,
    String? publisher,
    String? publishedDate,
    String? description,
    String? language,
    int? pages,
    String? image,
    int? price,
    double? rating,
    int? totalReviews,
    int? stockQuantity,
    int? availableQuantity,
    int? borrowedQuantity,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminBookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      genres: genres ?? this.genres,
      publisher: publisher ?? this.publisher,
      publishedDate: publishedDate ?? this.publishedDate,
      description: description ?? this.description,
      language: language ?? this.language,
      pages: pages ?? this.pages,
      image: image ?? this.image,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      borrowedQuantity: borrowedQuantity ?? this.borrowedQuantity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Inventory Stats Model
class InventoryStats {
  final int totalBooks;
  final int totalCopies;
  final int availableCopies;
  final int borrowedCopies;

  InventoryStats({
    required this.totalBooks,
    required this.totalCopies,
    required this.availableCopies,
    required this.borrowedCopies,
  });

  factory InventoryStats.fromBooks(List<AdminBookModel> books) {
    int totalCopies = 0;
    int availableCopies = 0;
    int borrowedCopies = 0;

    for (var book in books) {
      totalCopies += book.stockQuantity;
      availableCopies += book.availableQuantity;
      borrowedCopies += book.borrowedQuantity;
    }

    return InventoryStats(
      totalBooks: books.length,
      totalCopies: totalCopies,
      availableCopies: availableCopies,
      borrowedCopies: borrowedCopies,
    );
  }
}
