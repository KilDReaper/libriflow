import 'package:flutter/material.dart';
import 'package:libriflow/common/mysnackbar.dart';
import 'package:libriflow/features/auth/presentation/views/login_view.dart';
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                height: 140,
                width: 140,
                child: Image.asset("assets/images/Logo.png"),
              ),
            ),

            const SizedBox(height: 10),

            // TEXTFIELDS
            MyTextFieldWidget(
              controller: nameController,
              hintText: "Full Name",
              icon: Icons.close,
            ),

            MyTextFieldWidget(
              controller: emailController,
              hintText: "Email",
              icon: Icons.close,
            ),

            MyTextFieldWidget(
              controller: passwordController,
              hintText: "Password",
              isPassword: true,
              icon: Icons.visibility,
            ),

            const SizedBox(height: 15),

            // SIGNUP BUTTON
            MyButtonWidgets(
              text: "Create Account",
              color: const Color(0xffF25C58),
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
                    background: Colors.green,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Already have an account? Log in here",
                style: TextStyle(color: Colors.black54),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
