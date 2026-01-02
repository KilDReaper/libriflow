import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:libriflow/common/mysnackbar.dart';
import 'package:libriflow/widget/my_textformfeild.dart';
import 'package:libriflow/widget/mybutton.dart';
import '../../presentation/controllers/auth_controller.dart';
import 'signup_view.dart';
import '../../../home/presentation/views/home_view.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthController controller = AuthController(Hive.box('users'));

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
                onPressed: () {
                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    MySnackBar.show(
                      context,
                      message: "Fields cannot be empty!",
                      background: Colors.red,
                    );
                    return;
                  }

                  final success = controller.login(
                    emailController.text,
                    passwordController.text,
                  );

                  if (!success) {
                    MySnackBar.show(
                      context,
                      message: "Invalid email or password",
                      background: Colors.red,
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeView()),
                    );
                  }
                },
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SignupView(),

























































































































































