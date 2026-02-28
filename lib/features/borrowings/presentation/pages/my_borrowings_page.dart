import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/borrowing.dart';
import '../providers/borrowing_provider.dart';
import 'borrowing_details_page.dart';

class MyBorrowingsPage extends StatefulWidget {
  const MyBorrowingsPage({super.key});

  @override
  State<MyBorrowingsPage> createState() => _MyBorrowingsPageState();
}

class _MyBorrowingsPageState extends State<MyBorrowingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BorrowingProvider>().getMyBorrowings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Borrowings'),
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
                    onPressed: () => borrowingProvider.getMyBorrowings(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (borrowingProvider.borrowings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_outlined, size: 64),
                  SizedBox(height: 16),
                  Text('No borrowings yet'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => borrowingProvider.getMyBorrowings(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: borrowingProvider.borrowings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final borrowing = borrowingProvider.borrowings[index];
                return _BorrowingCard(borrowing: borrowing);
              },
            ),
          );
        },
      ),
    );
  }
}

class _BorrowingCard extends StatelessWidget {
  final Borrowing borrowing;

  const _BorrowingCard({required this.borrowing});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  BorrowingDetailsPage(borrowing: borrowing),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          borrowing.book.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${borrowing.book.author}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: borrowing.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Borrowed: ${borrowing.borrowDate.toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Due: ${borrowing.dueDate.toString().split(' ')[0]}',
                        style: TextStyle(
                          fontSize: 12,
                          color: borrowing.isOverdue ? Colors.red : Colors.grey[600],
                          fontWeight: borrowing.isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  if (borrowing.fineAmount > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Fine: Rs.${borrowing.fineAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!borrowing.finePaid)
                          const Text(
                            'Unpaid',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'active':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        icon = Icons.check_circle;
        break;
      case 'returned':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        icon = Icons.done_all;
        break;
      case 'overdue':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        icon = Icons.warning;
        break;
      case 'lost':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        icon = Icons.report_problem;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
