import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:libriflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:libriflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:libriflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:libriflow/features/auth/presentation/views/signup_page.dart';
import 'package:libriflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:libriflow/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:libriflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:libriflow/features/auth/domain/usecases/login_user.dart';
import 'package:libriflow/features/auth/domain/usecases/signup_user.dart';
import 'package:libriflow/shared/utils/mysnackbar.dart';
import 'package:libriflow/shared/widgets/my_textformfeild.dart';
import 'package:libriflow/shared/widgets/mybutton.dart';
import 'package:libriflow/core/permissions/permission_service.dart';
import '../../../home/presentation/views/home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late final AuthBloc authBloc;
  late final StreamSubscription authSubscription;

  @override
  void initState() {
    super.initState();

    final local = AuthLocalDatasourceImpl(Hive.box('auth'));
    final remote = AuthRemoteDatasourceImpl();
    final repository = AuthRepositoryImpl(local: local, remote: remote);

    authBloc = AuthBloc(
      loginUser: LoginUser(repository),
      signupUser: SignupUser(repository),
      repository: repository,
    );

    authSubscription = authBloc.stream.listen((state) async {
      if (state is AuthLoggedIn) {
        final permissionGranted = await PermissionService().requestCameraPermission();
        if (!permissionGranted && mounted) {
           MySnackBar.show(context, message: "Camera permission is required", background: Colors.red);
           return;
        }
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeView()));
      } else if (state is AuthError && mounted) {
        MySnackBar.show(context, message: state.message.replaceAll("Exception: ", ""), background: Colors.red);
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    authSubscription.cancel();
    authBloc.close();
    super.dispose();
  }

  void _login() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      MySnackBar.show(context, message: "Please fill all fields", background: Colors.red);
      return;
    }
    authBloc.add(LoginRequested(email: emailController.text.trim(), password: passwordController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 40),
              SizedBox(height: 140, width: 140, child: Image.asset("assets/images/Logo.png")),
              const SizedBox(height: 30),
              MyTextFieldWidget(controller: emailController, hintText: "Email", icon: Icons.mail),
              MyTextFieldWidget(controller: passwordController, hintText: "Password", isPassword: true, icon: Icons.lock),
              const SizedBox(height: 25),
              MyButtonWidgets(text: "Log In", color: const Color(0xffF25C58), onPressed: _login),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupView())),
                child: const Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}