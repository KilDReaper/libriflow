import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/signup_user.dart';
import 'auth_bloc.dart';

class AuthProvider extends StatelessWidget {
  final Widget child;

  const AuthProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final local = AuthLocalDatasourceImpl(Hive.box('auth'));
    final remote = AuthRemoteDatasourceImpl();
    final repository = AuthRepositoryImpl(local: local, remote: remote);
    final loginUser = LoginUser(repository);
    final signupUser = SignupUser(repository);

    return BlocProvider(
      create: (_) => AuthBloc(
        loginUser: loginUser,
        signupUser: signupUser,
        repository: repository,
      ),
      child: child,
    );
  }
}
