import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../shared/utils/image_url_resolver.dart';
import '../../../../shared/utils/mysnackbar.dart';
import '../../../home/presentation/views/book_details_page.dart';
import '../../domain/entities/recommendation.dart';
import '../providers/recommendation_provider.dart';

class RecommendedBooksPage extends StatefulWidget {
  final String bookType;
  final String course;
  final String className;

  const RecommendedBooksPage({
    super.key,
    required this.bookType,
    required this.course,
    required this.className,
  });

  @override
  State<RecommendedBooksPage> createState() => _RecommendedBooksPageState();
}

class _RecommendedBooksPageState extends State<RecommendedBooksPage> {
  late final TextEditingController _courseController;
  late final TextEditingController _classController;
  late final TextEditingController _genreController;
  late final TextEditingController _authorController;
  late final TextEditingController _keywordsController;
  late String _mode;

  bool get _isAcademic => _mode == 'academic';

  @override
  void initState() {
    super.initState();
    _courseController = TextEditingController(text: widget.course);
    _classController = TextEditingController(text: widget.className);
    _genreController = TextEditingController();
    _authorController = TextEditingController();
    _keywordsController = TextEditingController();
    _mode = (widget.bookType == 'non-course' || widget.bookType == 'non-academic')
        ? 'non-academic'
        : 'academic';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRecommendations();
    });
  }

  @override
  void dispose() {
    _courseController.dispose();
    _classController.dispose();
    _genreController.dispose();
    _authorController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecommendations() {
    return context.read<RecommendationProvider>().fetchRecommendations(
          bookType: _isAcademic ? 'course' : 'non-course',
          course: _isAcademic ? _courseController.text.trim() : null,
          className: _isAcademic ? _classController.text.trim() : null,
          genre: !_isAcademic ? _genreController.text.trim() : null,
          preferredAuthor: !_isAcademic ? _authorController.text.trim() : null,
          keywords: !_isAcademic ? _keywordsController.text.trim() : null,
        );
  }

  Widget _buildModeButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 42,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor:
                selected ? const Color(0xFF1A73E8) : Colors.blue.shade50,
            foregroundColor: selected ? Colors.white : Colors.blue.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel(RecommendationProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommendation Type',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildModeButton(
                label: 'Academic',
                selected: _isAcademic,
                onTap: () {
                  if (_mode == 'academic') return;
                  setState(() => _mode = 'academic');
                },
              ),
              const SizedBox(width: 10),
              _buildModeButton(
                label: 'Non-Academic',
                selected: !_isAcademic,
                onTap: () {
                  if (_mode == 'non-academic') return;
                  setState(() => _mode = 'non-academic');
                },
              ),
            ],
          ),
          if (_isAcademic) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _courseController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Course',
                hintText: 'e.g. Computer Science',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _classController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _fetchRecommendations(),
              decoration: const InputDecoration(
                labelText: 'Class',
                hintText: 'e.g. 100 Level / Grade 12',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            TextField(
              controller: _genreController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Genre',
                hintText: 'e.g. Fantasy, Self-help, Mystery',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _authorController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Preferred Author (Optional)',
                hintText: 'e.g. Agatha Christie',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _keywordsController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _fetchRecommendations(),
              decoration: const InputDecoration(
                labelText: 'Keywords (Optional)',
                hintText: 'e.g. adventure, dragons, coming of age',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: provider.isLoading ? null : _fetchRecommendations,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Get Recommendations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(RecommendationProvider provider) {
    if (provider.isLoading) {
      return const _ShimmerGrid();
    }

    if (provider.status == RecommendationStatus.error) {
      return _ErrorState(
        onRetry: _fetchRecommendations,
      );
    }

    if (provider.items.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchRecommendations,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.6,
        ),
        itemBuilder: (context, index) {
          final item = provider.items[index];
          return _RecommendationCard(item: item);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recommendations'),
        elevation: 2,
        backgroundColor: const Color(0xFF1A73E8),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade50,
      body: Consumer<RecommendationProvider>(
        builder: (context, provider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.status == RecommendationStatus.error &&
                provider.errorMessage != null) {
              MySnackBar.show(
                context,
                message: provider.errorMessage!,
                background: Colors.red,
              );
            }
          });

          return Column(
            children: [
              _buildControlPanel(provider),
              Expanded(child: _buildContent(provider)),
            ],
          );
        },
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation item;

  const _RecommendationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final safeCoverUrl = resolveBookImageUrl(item.coverUrl);

    return Material(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookDetailsPage(
                bookId: item.id,
                title: item.title,
                author: item.author,
                image: safeCoverUrl,
                section: 'Recommended',
                price: 0,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: isNetworkImageUrl(safeCoverUrl)
                        ? Image.network(
                            safeCoverUrl,
                            fit: BoxFit.cover,
                            height: 140,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey.shade200,
                              height: 140,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          )
                        : Image.asset(
                            safeCoverUrl,
                            fit: BoxFit.cover,
                            height: 140,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey.shade200,
                              height: 140,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'AI Pick',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookDetailsPage(
                                  bookId: item.id,
                                  title: item.title,
                                  author: item.author,
                                  image: safeCoverUrl,
                                  section: 'Recommended',
                                  price: 0,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A73E8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No recommendations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for personalized picks.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
