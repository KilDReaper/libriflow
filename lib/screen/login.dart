import 'package:flutter/material.dart';
import 'package:libriflow/common/mysnackbar.dart';
import 'package:libriflow/screen/dashboard.dart';
import 'package:libriflow/screen/signup.dart';
import 'package:libriflow/widget/my_textformfeild.dart';
import 'package:libriflow/widget/mybutton.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              MyTextFieldWidget(
                controller: emailController,
                hintText: "Email",
              ),

              // Password
              MyTextFieldWidget(
                controller: passwordController,
                hintText: "Password",
              ),

              const SizedBox(height: 20),

              // Login Button
              MyButtonWidgets(
                text: "Login",
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
                        builder: (context) => const DashboardScreen(),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 15),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: const Text(
                  "Don't have an account? Signup",
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
