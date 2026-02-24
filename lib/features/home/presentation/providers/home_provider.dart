import 'package:flutter/material.dart';
import '../../domain/usecases/get_current_tab_usecase.dart';
import '../../domain/usecases/change_tab_usecase.dart';

class HomeProvider extends ChangeNotifier {
  final ChangeTabUseCase changeTabUseCase;
  final GetCurrentTabUseCase getCurrentTabUseCase;

  int _currentIndex = 0;

  HomeProvider({
    required this.changeTabUseCase,
    required this.getCurrentTabUseCase,
  }) {
    _currentIndex = getCurrentTabUseCase();
  }

  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    changeTabUseCase(index);
    _currentIndex = index;
    notifyListeners();
  }
}
