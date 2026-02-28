import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import 'pay_fine_page.dart';

class UnpaidFinesPage extends StatefulWidget {
  const UnpaidFinesPage({super.key});

  @override
  State<UnpaidFinesPage> createState() => _UnpaidFinesPageState();
}

class _UnpaidFinesPageState extends State<UnpaidFinesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().getUnpaidFines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unpaid Fines'),
        centerTitle: true,
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, _) {
          if (paymentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paymentProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(paymentProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        paymentProvider.getUnpaidFines(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (paymentProvider.unpaidFines.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('No unpaid fines'),
                ],
              ),
            );
          }

          final totalUnpaid = paymentProvider.totalUnpaidFines;

          return Column(
            children: [
              // Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red.withOpacity(0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Unpaid Fines',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rs.${totalUnpaid.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              // List of Fines
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => paymentProvider.getUnpaidFines(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: paymentProvider.unpaidFines.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final fine = paymentProvider.unpaidFines[index];
                      return _FineCard(fine: fine);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, _) {
          if (paymentProvider.unpaidFines.isEmpty) {
            return const SizedBox.shrink();
          }

          final totalUnpaid = paymentProvider.totalUnpaidFines;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Due:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Rs.${totalUnpaid.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              PayFinePage(totalAmount: totalUnpaid),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Pay All Fines'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FineCard extends StatelessWidget {
  final fine;

  const _FineCard({required this.fine});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PayFinePage(
                totalAmount: fine.fineAmount,
                borrowingId: fine.borrowingId,
              ),
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
                    child: Text(
                      fine.bookTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Rs.${fine.fineAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
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
                        'Due Date:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        fine.dueDate.toString().split(' ')[0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Days Overdue:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        fine.daysOverdue.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PayFinePage(
                          totalAmount: fine.fineAmount,
                          borrowingId: fine.borrowingId,
                        ),
                      ),
                    );
                  },
                  child: const Text('Pay Fine'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
