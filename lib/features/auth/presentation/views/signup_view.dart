import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:libriflow/common/mysnackbar.dart';
import 'package:libriflow/features/auth/presentation/views/login_view.dart';
import 'package:libriflow/widget/my_textformfeild.dart';
import 'package:libriflow/widget/mybutton.dart';
import '../../presentation/controllers/auth_controller.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = AuthController(Hive.box('users'));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
                controller: nameController,
                hintText: "Name",
                icon: Icons.person,
              ),
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
                text: "Sign Up",
                color: const Color(0xffF25C58),
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    MySnackBar.show(
                      context,
                      message: "Fields cannot be empty",
                      background: Colors.red,
                    );
                    return;
                  }
              const SizedBox(height: 20);
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginView()),
                  );
                },
                child: const Text("Already have an account? login"),
              );

                  final success = await authController.signup(
                    nameController.text,
                    emailController.text,
                    passwordController.text,
                  );

                  if (!success) {
                    MySnackBar.show(
                      context,
                      message: "Email already exists",
                      background: Colors.red,
                    );
                    return;
                  }

                  MySnackBar.show(
                    context,
                    message: "Signup successful",
                    background: Colors.green,
                  );

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
