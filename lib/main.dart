import 'package:flutter/material.dart';
import 'package:libriflow/features/auth/presentation/views/login_view.dart';

void main() {
  runApp(const LibriFlowApp());
}

class LibriFlowApp extends StatelessWidget {
  const LibriFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LibriFlow',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'OpenSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
        ),
      ),
      home: LoginScreen(),
    );
  }
}
