import 'package:flutter/material.dart';

class MyTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final IconData icon;

  const MyTextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.icon = Icons.close, // default icon
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: InputBorder.none,
            suffixIcon: Icon(
              icon,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
