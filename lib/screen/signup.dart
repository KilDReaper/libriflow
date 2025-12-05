import 'package:flutter/material.dart';
import 'package:libriflow/common/mysnackbar.dart';
import 'package:libriflow/screen/login.dart';
import 'package:libriflow/widget/my_textformfeild.dart';
import 'package:libriflow/widget/mybutton.dart';


class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final nameController = TextEditingController();
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
                "Signup",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              MyTextFieldWidget(
                controller: nameController,
                hintText: "Full Name",
              ),

              MyTextFieldWidget(
                controller: emailController,
                hintText: "Email",
              ),

              MyTextFieldWidget(
                controller: passwordController,
                hintText: "Password",
              ),

              const SizedBox(height: 20),

              MyButtonWidgets(
                text: "Signup",
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    MySnackBar.show(
                      context,
                      message: "All fields are required!",
                      background: Colors.red,
                    );
                  } else {
                    MySnackBar.show(
                      context,
                      message: "Signup Successful!",
                      background: Colors.blue,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 15),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Already have an account? Login",
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
