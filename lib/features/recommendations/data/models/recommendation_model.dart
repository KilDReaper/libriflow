import '../../domain/entities/recommendation.dart';

class RecommendationModel extends Recommendation {
  const RecommendationModel({
    required super.id,
    required super.title,
    required super.author,
    required super.coverUrl,
    required super.rating,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    final dynamic authorValue = json['author'] ?? json['authors'];
    final String author = authorValue is List
        ? (authorValue.isNotEmpty ? authorValue.first.toString() : 'Unknown')
        : (authorValue ?? 'Unknown').toString();

    return RecommendationModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      author: author,
      coverUrl: (json['coverImageUrl'] ??
              json['coverUrl'] ??
              json['imageUrl'] ??
              json['image'] ??
              '')
          .toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'rating': rating,
    };
  }
}
