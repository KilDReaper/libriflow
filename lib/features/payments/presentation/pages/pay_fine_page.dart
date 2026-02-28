import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';

class PayFinePage extends StatefulWidget {
  final double totalAmount;
  final String? borrowingId;

  const PayFinePage({
    super.key,
    required this.totalAmount,
    this.borrowingId,
  });

  @override
  State<PayFinePage> createState() => _PayFinePageState();
}

class _PayFinePageState extends State<PayFinePage> {
  String? selectedPaymentMethod;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Fine'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Summary
            Card(
              color: Colors.blue.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Amount to Pay',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rs.${widget.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Payment Methods
            Text(
              'Select Payment Method',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _PaymentMethodOption(
              title: 'Khalti',
              subtitle: 'Pay with Khalti Wallet',
              icon: Icons.account_balance_wallet,
              value: 'khalti',
              selectedValue: selectedPaymentMethod,
              onChanged: (value) =>
                  setState(() => selectedPaymentMethod = value),
            ),
            _PaymentMethodOption(
              title: 'eSewa',
              subtitle: 'Pay with eSewa',
              icon: Icons.payment,
              value: 'esewa',
              selectedValue: selectedPaymentMethod,
              onChanged: (value) =>
                  setState(() => selectedPaymentMethod = value),
            ),
            _PaymentMethodOption(
              title: 'Stripe',
              subtitle: 'Pay with Credit/Debit Card',
              icon: Icons.credit_card,
              value: 'stripe',
              selectedValue: selectedPaymentMethod,
              onChanged: (value) =>
                  setState(() => selectedPaymentMethod = value),
            ),
            _PaymentMethodOption(
              title: 'Cash',
              subtitle: 'Pay at Library Counter',
              icon: Icons.attach_money,
              value: 'cash',
              selectedValue: selectedPaymentMethod,
              onChanged: (value) =>
                  setState(() => selectedPaymentMethod = value),
            ),
            const SizedBox(height: 32),
            // Pay Button
            Consumer<PaymentProvider>(
              builder: (context, paymentProvider, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (selectedPaymentMethod == null || isProcessing)
                        ? null
                        : () => _processPayment(context, paymentProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      isProcessing ? 'Processing...' : 'Proceed to Payment',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For cash payments, please visit the library counter with this reference',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(
    BuildContext context,
    PaymentProvider paymentProvider,
  ) async {
    if (selectedPaymentMethod == null) return;

    setState(() => isProcessing = true);

    try {
      final payment = await paymentProvider.createPayment(
        borrowingId: widget.borrowingId ?? '',
        amount: widget.totalAmount,
        paymentMethod: selectedPaymentMethod!,
      );

      if (!mounted) return;

      if (payment != null) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Payment Created'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment ID: ${payment.id}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                if (selectedPaymentMethod == 'khalti')
                  const Text(
                    'Please complete payment on Khalti and verify with the transaction ID.',
                  )
                else if (selectedPaymentMethod == 'esewa')
                  const Text(
                    'Please complete payment on eSewa and verify with the transaction ID.',
                  )
                else if (selectedPaymentMethod == 'stripe')
                  const Text(
                    'Please complete payment with your card details.',
                  )
                else
                  const Text(
                    'Please visit the library counter to complete payment.',
                  ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(paymentProvider.error ?? 'Failed to create payment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isProcessing = false);
    }
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String? selectedValue;
  final Function(String) onChanged;

  const _PaymentMethodOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue == value;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onChanged(value),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(icon, size: 32, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
