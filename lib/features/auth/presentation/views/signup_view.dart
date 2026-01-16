import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:libriflow/common/mysnackbar.dart';
import 'package:libriflow/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:libriflow/widget/my_textformfeild.dart';
import 'package:libriflow/widget/mybutton.dart';

import '../../presentation/controllers/auth_controller.dart';
import 'login_view.dart';

import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      MySnackBar.show(
        context,
        message: "Fields cannot be empty",
        background: Colors.red,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      MySnackBar.show(
        context,
        message: "Passwords do not match",
        background: Colors.red,
      );
      return;
    }

    try {
      await authController.signup(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      MySnackBar.show(
        context,
        message: "Account created successfully",
        background: Colors.green,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    } catch (e) {
      MySnackBar.show(
        context,
        message: "Signup failed. Try again.",
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
              MyTextFieldWidget(
                controller: confirmPasswordController,
                hintText: "Confirm Password",
                isPassword: true,
                icon: Icons.lock,
              ),
              const SizedBox(height: 25),
              MyButtonWidgets(
                text: "Sign Up",
                color: const Color(0xffF25C58),
                onPressed: _signup,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text("Already have an account? Log in"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
