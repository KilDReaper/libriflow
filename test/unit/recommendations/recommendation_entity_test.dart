import 'package:flutter_test/flutter_test.dart';
import 'package:libriflow/features/recommendations/domain/entities/recommendation.dart';

void main() {
  test('Recommendation entity stores provided values', () {
    const recommendation = Recommendation(
      id: 'rec-1',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      coverUrl: 'https://example.com/cover.jpg',
      rating: 4.8,
    );

    expect(recommendation.id, 'rec-1');
    expect(recommendation.title, 'Clean Code');
    expect(recommendation.author, 'Robert C. Martin');
    expect(recommendation.coverUrl, 'https://example.com/cover.jpg');
    expect(recommendation.rating, 4.8);
  });
}
