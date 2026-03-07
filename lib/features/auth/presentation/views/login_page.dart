import 'package:flutter/material.dart';
import 'package:libriflow/core/permissions/permission_service.dart';
import 'package:libriflow/features/home/presentation/views/home_view.dart';
import 'package:provider/provider.dart';
import 'package:libriflow/features/auth/presentation/providers/auth_provider.dart';
import 'package:libriflow/features/auth/presentation/views/signup_page.dart';
import 'package:libriflow/shared/utils/mysnackbar.dart';
import 'package:libriflow/shared/widgets/my_textformfeild.dart';
import 'package:libriflow/shared/widgets/mybutton.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check biometric availability when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkBiometricStatus();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      MySnackBar.show(context, message: "Please fill all fields", background: Colors.red);
      return;
    }
    context.read<AuthProvider>().login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
  }

  void _loginWithBiometric() {
    context.read<AuthProvider>().loginWithBiometric();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (authProvider.status == AuthStatus.loggedIn) {
              final permissionGranted = await PermissionService().requestCameraPermission();
              if (!permissionGranted && mounted) {
                MySnackBar.show(context, message: "Camera permission is required", background: Colors.red);
                return;
              }
              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeView()));
            } else if (authProvider.status == AuthStatus.error && authProvider.errorMessage != null) {
              MySnackBar.show(context, message: authProvider.errorMessage!, background: Colors.red);
              authProvider.clearError();
            }
          });

          return SafeArea(
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
                  authProvider.isLoading
                      ? const CircularProgressIndicator()
                      : MyButtonWidgets(text: "Log In", color: const Color(0xffF25C58), onPressed: _login),
                  const SizedBox(height: 20),
                  // Fingerprint button - only show if available
                  if (authProvider.isBiometricAvailable)
                    Column(
                      children: [
                        Container(
                          height: 1,
                          color: Colors.grey[300],
                          margin: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        GestureDetector(
                          onTap: authProvider.isLoading ? null : _loginWithBiometric,
                          child: Column(
                            children: [
                              Icon(
                                Icons.fingerprint,
                                size: 48,
                                color: authProvider.isLoading ? Colors.grey : const Color(0xffF25C58),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Use Fingerprint',
                                style: TextStyle(
                                  color: authProvider.isLoading ? Colors.grey : const Color(0xffF25C58),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupView())),
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}