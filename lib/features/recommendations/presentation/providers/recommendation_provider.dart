import 'package:flutter/material.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/usecases/get_recommendations.dart';

enum RecommendationStatus { initial, loading, success, error }

class RecommendationProvider extends ChangeNotifier {
  final GetRecommendations getRecommendations;

  RecommendationStatus _status = RecommendationStatus.initial;
  List<Recommendation> _items = const [];
  String? _errorMessage;

  RecommendationProvider({
    required this.getRecommendations,
  });

  RecommendationStatus get status => _status;
  List<Recommendation> get items => _items;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == RecommendationStatus.loading;

  Future<void> fetchRecommendations({
    bool trending = false,
    String? genre,
    String? similarToBookId,
  }) async {
    _status = RecommendationStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await getRecommendations(
        trending: trending,
        genre: genre,
        similarToBookId: similarToBookId,
      );
      _status = RecommendationStatus.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = RecommendationStatus.error;
      notifyListeners();
    }
  }
}
