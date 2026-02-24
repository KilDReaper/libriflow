class Recommendation {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final double rating;

  const Recommendation({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.rating,
  });
}
