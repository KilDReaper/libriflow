import 'package:flutter/material.dart';
import '/common/mysnackbar.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> books = [
    {
      "title": "Clean Code",
      "author": "Robert C. Martin",
      "price": 15,
      "image": "assets/images/clean_code.png",
      "section": "Programming"
    },
    {
      "title": "Atomic Habits",
      "author": "James Clear",
      "price": 10,
      "image": "assets/images/atomic_habits.png",
      "section": "Self-help"
    },
    {
      "title": "Flutter Basics",
      "author": "Google",
      "price": 12,
      "image": "assets/images/flutter_basics.png",
      "section": "Technology"
    },
    {
      "title": "AI for Beginners",
      "author": "Andrew Ng",
      "price": 20,
      "image": "assets/images/ai_for_beginners.png",
      "section": "Artificial Intelligence"
    },
  ];

  late List<Map<String, dynamic>> filteredBooks;

  final List<String> categories = [
    "All",
    "Programming",
    "Self-help",
    "AI",
    "Technology",
  ];

  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    filteredBooks = List.from(books);
  }

  void searchBook(String query) {
    setState(() {
      filteredBooks = books.where((book) {
        final matchQuery = book["title"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            book["author"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
        final matchCategory = selectedCategory == "All"
            ? true
            : book["section"] == selectedCategory;
        return matchQuery && matchCategory;
      }).toList();
    });
  }

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      searchBook(searchController.text);
    });
  }

  Widget _categoryChip(String text) {
    final isSelected = text == selectedCategory;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(
          text,
          style: const TextStyle(fontFamily: "OpenSans"),
        ),
        selected: isSelected,
        onSelected: (_) => selectCategory(text),
        selectedColor: Colors.blue.shade300,
        backgroundColor: Colors.grey.shade200,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final crossCount = screenWidth > 1000
        ? 5
        : screenWidth > 800
            ? 4
            : screenWidth > 600
                ? 3
                : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text("LibriFlow Dashboard"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: searchBook,
              decoration: InputDecoration(
                hintText: "Search books",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {},
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: categories.map(_categoryChip).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 5,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        book["section"],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          book["image"],
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book["title"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        book["author"],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "\$${book["price"]}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                MySnackBar.show(
                                  context,
                                  message:
                                      "${book["title"]} rented successfully",
                                );
                              },
                              child: const Text(
                                "Rent",
                                style: TextStyle(fontFamily: "OpenSans"),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                MySnackBar.show(
                                  context,
                                  message:
                                      "${book["title"]} purchased successfully",
                                );
                              },
                              child: const Text(
                                "Buy",
                                style: TextStyle(
                                  fontFamily: "OpenSans",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
