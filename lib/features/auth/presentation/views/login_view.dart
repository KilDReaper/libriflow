import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:libriflow/common/mysnackbar.dart';
import 'package:libriflow/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:libriflow/widget/my_textformfeild.dart';
import 'package:libriflow/widget/mybutton.dart';

import '../../presentation/controllers/auth_controller.dart';
import '../../../home/presentation/views/home_view.dart';
import 'signup_view.dart';

import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late AuthController authController;

  @override
  void initState() {
    super.initState();

    final local = AuthLocalDatasource(Hive.box('auth'));
    final remote = AuthRemoteDatasource();
    final repository = AuthRepositoryImpl(
      local: local,
      remote: remote,
    );

    authController = AuthController(repository);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      MySnackBar.show(
        context,
        message: "Fields cannot be empty",
        background: Colors.red,
      );
      return;
    }

    try {
      await authController.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
    } catch (e) {
      MySnackBar.show(
        context,
        message: "Invalid email or password",
        background: Colors.red,
      );
    }
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
              SizedBox(
                height: 140,
                width: 140,
                child: Image.asset("assets/images/Logo.png"),
              ),
              const SizedBox(height: 30),
              MyTextFieldWidget(
                controller: emailController,
                hintText: "Email",
                icon: Icons.mail,
              ),
              MyTextFieldWidget(
                controller: passwordController,
                hintText: "Password",
                isPassword: true,
                icon: Icons.lock,
              ),
              const SizedBox(height: 25),
              MyButtonWidgets(
                text: "Log In",
                color: const Color(0xffF25C58),
                onPressed: _login,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupView()),
                  );
                },
                child: const Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
