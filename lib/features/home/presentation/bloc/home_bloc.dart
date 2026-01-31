import 'package:bloc/bloc.dart';
import 'package:libriflow/features/home/domain/usecases/get_current_tab_usecase.dart';
import '../../domain/usecases/change_tab_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ChangeTabUseCase changeTabUseCase;
  final GetCurrentTabUseCase getCurrentTabUseCase;

  HomeBloc({
    required this.changeTabUseCase,
    required this.getCurrentTabUseCase,
  }) : super(HomeInitial(getCurrentTabUseCase())) {
    on<ChangeTab>((event, emit) {
      changeTabUseCase(event.index);
      emit(HomeTabChanged(event.index));
    });
  }
}
