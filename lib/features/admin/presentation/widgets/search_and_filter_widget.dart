import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_books_provider.dart';

class SearchAndFilterWidget extends StatefulWidget {
  const SearchAndFilterWidget({super.key});

  @override
  State<SearchAndFilterWidget> createState() => _SearchAndFilterWidgetState();
}

class _SearchAndFilterWidgetState extends State<SearchAndFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AdminBooksProvider>();
    _searchController.text = provider.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<AdminBooksProvider>().setSearchQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminBooksProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by title, author, or ISBN...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            
            // Filters Row
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Genre Filter
                _FilterDropdown(
                  label: 'Genre',
                  value: provider.selectedGenre,
                  items: ['all', ...provider.availableGenres],
                  onChanged: (value) {
                    if (value != null) {
                      provider.setGenreFilter(value);
                    }
                  },
                ),
                
                // Status Filter
                _FilterDropdown(
                  label: 'Status',
                  value: provider.selectedStatus,
                  items: const ['all', 'available', 'out_of_stock', 'discontinued'],
                  onChanged: (value) {
                    if (value != null) {
                      provider.setStatusFilter(value);
                    }
                  },
                ),
                
                // Sort By
                _FilterDropdown(
                  label: 'Sort By',
                  value: provider.sortBy,
                  items: const ['title', 'author', 'price', 'rating', 'stock', 'available', 'createdAt'],
                  onChanged: (value) {
                    if (value != null) {
                      provider.setSorting(value);
                    }
                  },
                ),
                
                // Sort Order
                ActionChip(
                  avatar: Icon(
                    provider.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 18,
                  ),
                  label: Text(provider.sortAscending ? 'Ascending' : 'Descending'),
                  onPressed: () {
                    provider.setSorting(provider.sortBy, ascending: !provider.sortAscending);
                  },
                ),
                
                // Price Range Filter
                ActionChip(
                  avatar: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Price Range'),
                  onPressed: () {
                    _showPriceRangeDialog(context, provider);
                  },
                ),
                
                // Clear Filters
                if (provider.searchQuery.isNotEmpty ||
                    provider.selectedGenre != 'all' ||
                    provider.selectedStatus != 'all')
                  ActionChip(
                    avatar: const Icon(Icons.clear, size: 18),
                    label: const Text('Clear Filters'),
                    backgroundColor: Colors.red[50],
                    onPressed: () {
                      _searchController.clear();
                      provider.clearFilters();
                    },
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Results Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${provider.startIndex + 1}-${provider.endIndex} of ${provider.totalBooks} books',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                
                // Items per page
                DropdownButton<int>(
                  value: provider.itemsPerPage,
                  underline: const SizedBox.shrink(),
                  items: [10, 20, 50, 100].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value per page'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setItemsPerPage(value);
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showPriceRangeDialog(BuildContext context, AdminBooksProvider provider) {
    double minPrice = provider.minPrice;
    double maxPrice = provider.maxPrice;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter by Price Range'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('₹${minPrice.toInt()} - ₹${maxPrice.toInt()}'),
              const SizedBox(height: 16),
              RangeSlider(
                values: RangeValues(minPrice, maxPrice),
                min: 0,
                max: 10000,
                divisions: 100,
                labels: RangeLabels(
                  '₹${minPrice.toInt()}',
                  '₹${maxPrice.toInt()}',
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    minPrice = values.start;
                    maxPrice = values.end;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.setPriceRange(minPrice, maxPrice);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(_formatLabel(item)),
          );
        }).toList(),
        onChanged: onChanged,
        hint: Text(label),
      ),
    );
  }

  String _formatLabel(String value) {
    if (value == 'all') return 'All ${label}s';
    return value.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
