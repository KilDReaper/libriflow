import 'package:flutter/material.dart';
import 'recommended_books_page.dart';

class AiRecommendationOptionsPage extends StatefulWidget {
  const AiRecommendationOptionsPage({super.key});

  @override
  State<AiRecommendationOptionsPage> createState() =>
      _AiRecommendationOptionsPageState();
}

class _AiRecommendationOptionsPageState
    extends State<AiRecommendationOptionsPage> {
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _classController = TextEditingController();

  String _bookType = 'course';

  @override
  void dispose() {
    _courseController.dispose();
    _classController.dispose();
    super.dispose();
  }

  void _generate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecommendedBooksPage(
          bookType: _bookType,
          course: _courseController.text.trim(),
          className: _classController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recommendation Setup'),
        backgroundColor: const Color(0xFF1A73E8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Book Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'course',
                  label: Text('Course Books'),
                ),
                ButtonSegment<String>(
                  value: 'non-course',
                  label: Text('Non-Course Books'),
                ),
              ],
              selected: <String>{_bookType},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _bookType = selection.first;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _courseController,
              decoration: const InputDecoration(
                labelText: 'Course',
                hintText: 'e.g. Computer Science',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _classController,
              decoration: const InputDecoration(
                labelText: 'Class',
                hintText: 'e.g. 100 Level / Grade 12',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generate,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate with AI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}