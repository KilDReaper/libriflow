import 'package:bloc/bloc.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/signup_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final SignupUser signupUser;
  final AuthRepository repository;

  AuthBloc({
    required this.loginUser,
    required this.signupUser,
    required this.repository,
  }) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUser(event.email, event.password);
        emit(AuthLoggedIn(user.token));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignupRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signupUser(
          event.email,
          event.username,
          event.phone,
          event.password,
          event.confirmPassword,
        );
        emit(AuthLoggedIn(user.token));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await repository.logout();
      emit(AuthLoggedOut());
    });
  }
}
