import 'package:flutter/material.dart';
import 'package:libriflow/screen/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'OpenSans',
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
