import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libriflow/features/auth/presentation/providers/auth_provider.dart';
import 'package:libriflow/features/auth/presentation/views/login_page.dart';
import 'package:libriflow/shared/utils/mysnackbar.dart';
import 'package:libriflow/shared/widgets/my_textformfeild.dart';
import 'package:libriflow/shared/widgets/mybutton.dart';

class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (emailController.text.isEmpty || usernameController.text.isEmpty || 
        phoneController.text.isEmpty || passwordController.text.isEmpty) {
      MySnackBar.show(context, message: "Fields cannot be empty", background: Colors.red);
      return;
    }

    ref.read(authProvider.notifier).signup(
      email: emailController.text.trim(),
      username: usernameController.text.trim(),
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    ref.listen(authProvider, (previous, next) {
      if (next.status == AuthStatus.loggedIn) {
        if (mounted) {
          MySnackBar.show(context, message: "Account created successfully", background: Colors.green);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView()));
        }
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        MySnackBar.show(context, message: next.errorMessage!, background: Colors.red);
        ref.read(authProvider.notifier).clearError();
      }
    });

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
                  MyTextFieldWidget(controller: usernameController, hintText: "Username", icon: Icons.person),
                  MyTextFieldWidget(controller: phoneController, hintText: "Phone Number", icon: Icons.phone),
                  MyTextFieldWidget(controller: passwordController, hintText: "Password", isPassword: true, icon: Icons.lock),
                  MyTextFieldWidget(controller: confirmPasswordController, hintText: "Confirm Password", isPassword: true, icon: Icons.lock),
                  const SizedBox(height: 25),
                  authState.isLoading
                      ? const CircularProgressIndicator()
                      : MyButtonWidgets(text: "Sign Up", color: const Color(0xffF25C58), onPressed: _signup),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginView())),
                    child: const Text("Already have an account? Log in"),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}