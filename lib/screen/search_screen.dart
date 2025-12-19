import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller = TextEditingController();

  final List<String> categories = [
    "Fiction",
    "Sci-Fi",
    "Romance",
    "Programming",
    "History",
    "Horror",
  ];

  final List<Map<String, dynamic>> books = [
    {
      "title": "Flutter for Beginners",
      "author": "John Adams",
      "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ855e1EnC0jUgGQbFetgA1Kvwog6HQf2lfkA&s"
    },
    {
      "title": "Data Structures in Python",
      "author": "Emily Clark",
      "image": "https://picsum.photos/200"
    },
    {
      "title": "The Silent Patient",
      "author": "Alex Michaelides",
      "image": "https://static.wixstatic.com/media/b077d4_c764f44d42d840a29ae3ea49155d50de~mv2.jpg/v1/fill/w_414,h_454,al_c,q_80,usm_1.20_1.00_0.01,enc_avif,quality_auto/b077d4_c764f44d42d840a29ae3ea49155d50de~mv2.jpg"
    },
  ];

  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final filtered = books
        .where((b) => b["title"].toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Search Books")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
              ),
              child: TextField(
                controller: controller,
                onChanged: (v) {
                  setState(() {
                    searchText = v;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search books...",
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      setState(() {
                        searchText = "";
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categories
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(c),
                          backgroundColor: Colors.blue.shade50,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: searchText.isEmpty
                  ? const Center(
                      child: Text(
                        "Search any book to begin",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : GridView.builder(
                      itemCount: filtered.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final book = filtered[index];
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 5,
                                spreadRadius: 1,
                                color: Colors.black.withOpacity(0.05),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  book["image"],
                                  height: 700,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                book["title"],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book["author"],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
