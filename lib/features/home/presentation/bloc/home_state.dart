abstract class HomeState {}

class HomeInitial extends HomeState {
  final int currentIndex;
  HomeInitial(this.currentIndex);
}

class HomeTabChanged extends HomeState {
  final int currentIndex;
  HomeTabChanged(this.currentIndex);
}
