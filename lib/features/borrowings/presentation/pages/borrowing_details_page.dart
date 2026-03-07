import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/borrowing.dart';
import '../providers/borrowing_provider.dart';

class BorrowingDetailsPage extends StatefulWidget {
  final Borrowing borrowing;

  const BorrowingDetailsPage({
    super.key,
    required this.borrowing,
  });

  @override
  State<BorrowingDetailsPage> createState() => _BorrowingDetailsPageState();
}

class _BorrowingDetailsPageState extends State<BorrowingDetailsPage> {
  bool isReturning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrowing Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.borrowing.book.coverImage != null)
                          Container(
                            width: 80,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.borrowing.book.coverImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.book);
                                },
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 80,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300],
                            ),
                            child: const Icon(Icons.book, size: 40),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.borrowing.book.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'by ${widget.borrowing.book.author}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ISBN: ${widget.borrowing.book.isbn}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Status and Timeline
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Borrowing Timeline',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _TimelineItem(
                      title: 'Borrowed',
                      date: widget.borrowing.borrowDate,
                      isCompleted: true,
                    ),
                    _TimelineItem(
                      title: 'Due Date',
                      date: widget.borrowing.dueDate,
                      isCompleted: true,
                      isOverdue: widget.borrowing.isOverdue,
                    ),
                    if (widget.borrowing.returnedDate != null)
                      _TimelineItem(
                        title: 'Returned',
                        date: widget.borrowing.returnedDate!,
                        isCompleted: true,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        _StatusBadge(status: widget.borrowing.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (widget.borrowing.isOverdue)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This book is ${widget.borrowing.daysOverdue} days overdue',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (widget.borrowing.fineAmount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Card(
                  color: Colors.red.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fine Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.red,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Fine Amount:'),
                            Text(
                              'Rs.${widget.borrowing.fineAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Payment Status:'),
                            Text(
                              widget.borrowing.finePaid ? 'PAID' : 'UNPAID',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    widget.borrowing.finePaid ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Action Buttons
            if (widget.borrowing.status == 'active' &&
                !widget.borrowing.isReturned &&
                !widget.borrowing.isLost)
              SizedBox(
                width: double.infinity,
                child: Consumer<BorrowingProvider>(
                  builder: (context, borrowingProvider, _) {
                    return ElevatedButton.icon(
                      onPressed: isReturning ? null : () => _showReturnDialog(context),
                      icon: isReturning
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle),
                      label: Text(isReturning ? 'Returning...' : 'Return Book'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showReturnDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Book?'),
        content: const Text(
          'Are you sure you want to return this book? '
          'Any unpaid fines must be settled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _returnBook(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Return'),
          ),
        ],
      ),
    );
  }

  Future<void> _returnBook(BuildContext context) async {
    setState(() => isReturning = true);
    final borrowingProvider = context.read<BorrowingProvider>();
    final success = await borrowingProvider.returnBorrowing(widget.borrowing.id);

    setState(() => isReturning = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book returned successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(borrowingProvider.error ?? 'Failed to return book'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final DateTime date;
  final bool isCompleted;
  final bool isOverdue;

  const _TimelineItem({
    required this.title,
    required this.date,
    this.isCompleted = false,
    this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isOverdue ? Colors.red : Colors.green,
                child: Icon(
                  isOverdue ? Icons.warning : Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              if (title != 'Returned')
                Container(
                  width: 2,
                  height: 30,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                dateString,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
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

    switch (status) {
      case 'active':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case 'returned':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'overdue':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      case 'lost':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
