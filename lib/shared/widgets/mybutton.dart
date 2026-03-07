import 'package:flutter/material.dart';

class MyButtonWidgets extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const MyButtonWidgets({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xffF25C58), // soft red like screenshot
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
