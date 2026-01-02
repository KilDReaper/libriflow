import 'package:flutter/material.dart';
import 'package:libriflow/common/mysnackbar.dart';
import 'package:libriflow/screen/home_screen.dart';
import 'package:libriflow/features/auth/presentation/views/signup_view.dart';
import 'package:libriflow/widget/my_textformfeild.dart';
import 'package:libriflow/widget/mybutton.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
                  } else {
                    MySnackBar.show(
                      context,
                      message: "Login Successful!",
                      background: Colors.green,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
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
                      builder: (context) => SignupScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Don't have an account? Sign up here",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
