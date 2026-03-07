import 'dart:async';
import 'package:flutter/material.dart';

class SearchAndFilterBar extends StatefulWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final List<String> genres;
  final String selectedGenre;
  final Function(String) onGenreChanged;
  final String sortBy;
  final Function(String) onSortChanged;
  final VoidCallback onClearFilters;
  final bool hasActiveFilters;

  const SearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.genres,
    required this.selectedGenre,
    required this.onGenreChanged,
    required this.sortBy,
    required this.onSortChanged,
    required this.onClearFilters,
    this.hasActiveFilters = false,
  });

  @override
  State<SearchAndFilterBar> createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends State<SearchAndFilterBar> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearchChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: widget.searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by title, author, ISBN...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1A73E8)),
              suffixIcon: widget.searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.searchController.clear();
                        widget.onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Genre Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<String>(
                    value: widget.selectedGenre,
                    underline: const SizedBox.shrink(),
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    items: widget.genres.map((String genre) {
                      return DropdownMenuItem<String>(
                        value: genre,
                        child: Text(
                          genre,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) widget.onGenreChanged(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Sort Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<String>(
                    value: widget.sortBy,
                    underline: const SizedBox.shrink(),
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    items: const [
                      DropdownMenuItem(value: 'title', child: Text('Title')),
                      DropdownMenuItem(value: 'author', child: Text('Author')),
                      DropdownMenuItem(value: 'rating', child: Text('Rating')),
                      DropdownMenuItem(value: 'newest', child: Text('Newest')),
                      DropdownMenuItem(value: 'price', child: Text('Price')),
                    ],
                    onChanged: (value) {
                      if (value != null) widget.onSortChanged(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Clear Filters
                if (widget.hasActiveFilters)
                  OutlinedButton.icon(
                    onPressed: widget.onClearFilters,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
