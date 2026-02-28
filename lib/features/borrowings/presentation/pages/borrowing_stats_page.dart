import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/borrowing_provider.dart';

class BorrowingStatsPage extends StatefulWidget {
  const BorrowingStatsPage({super.key});

  @override
  State<BorrowingStatsPage> createState() => _BorrowingStatsPageState();
}

class _BorrowingStatsPageState extends State<BorrowingStatsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BorrowingProvider>().getBorrowingStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrowing Statistics'),
        centerTitle: true,
      ),
      body: Consumer<BorrowingProvider>(
        builder: (context, borrowingProvider, _) {
          if (borrowingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (borrowingProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(borrowingProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        borrowingProvider.getBorrowingStats(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stats = borrowingProvider.stats;
          if (stats == null) {
            return const Center(child: Text('No data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _StatCard(
                      title: 'Active Books',
                      value: stats.activeBorrowings.toString(),
                      color: Colors.blue,
                      icon: Icons.library_books,
                    ),
                    _StatCard(
                      title: 'Returned',
                      value: stats.returnedBorrowings.toString(),
                      color: Colors.green,
                      icon: Icons.done_all,
                    ),
                    _StatCard(
                      title: 'Overdue',
                      value: stats.overdueBorrowings.toString(),
                      color: Colors.red,
                      icon: Icons.warning,
                    ),
                    _StatCard(
                      title: 'Total Fines',
                      value: 'Rs.${stats.totalFines.toStringAsFixed(2)}',
                      color: Colors.orange,
                      icon: Icons.payment,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Fine Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fine Summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _FineRow(
                          label: 'Total Fines',
                          amount: stats.totalFines,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _FineRow(
                          label: 'Paid Fines',
                          amount: stats.paidFines,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _FineRow(
                          label: 'Unpaid Fines',
                          amount: stats.unpaidFines,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: LinearProgressIndicator(
                            value: stats.totalFines > 0
                                ? stats.paidFines / stats.totalFines
                                : 0,
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(
                              stats.paidFines / stats.totalFines >= 1
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            '${((stats.paidFines / (stats.totalFines > 0 ? stats.totalFines : 1)) * 100).toStringAsFixed(1)}% Paid',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FineRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _FineRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          'Rs.${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }
}
