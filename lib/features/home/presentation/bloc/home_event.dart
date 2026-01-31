abstract class HomeEvent {}

class ChangeTab extends HomeEvent {
  final int index;
  ChangeTab(this.index);
}
