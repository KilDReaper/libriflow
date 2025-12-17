import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Books")),
      body: const Center(
        child: Text(
          "Search Books Here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
