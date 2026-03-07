import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/utils/mysnackbar.dart';
import '../../domain/entities/reservation.dart';
import '../providers/reservation_provider.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationProvider>().fetchMyReservations();
    });
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.successMessage != null) {
              MySnackBar.show(context, message: provider.successMessage!);
              provider.clearMessages();
            }
            if (provider.errorMessage != null) {
              MySnackBar.show(
                context,
                message: provider.errorMessage!,
                background: Colors.red,
              );
              provider.clearMessages();
            }
          });

          if (provider.isFetching && provider.reservations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.reservations.isEmpty) {
            return const Center(child: Text('No reservations yet.'));
          }

          return RefreshIndicator(
            onRefresh: provider.fetchMyReservations,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.reservations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reservation = provider.reservations[index];
                return _ReservationCard(
                  reservation: reservation,
                  onCancel: () => provider.cancelReservation(reservation.id),
                  isCancelling: provider.isCancelling,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onCancel;
  final bool isCancelling;

  const _ReservationCard({
    required this.reservation,
    required this.onCancel,
    required this.isCancelling,
  });

  @override
  Widget build(BuildContext context) {
    final status = reservation.status.toLowerCase();
    final canCancel = status != 'cancelled';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reservation.bookTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.queue, size: 16, color: Colors.blueGrey),
              const SizedBox(width: 6),
              Text('Queue position: ${reservation.queuePosition}'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.timer, size: 16, color: Colors.orange),
              const SizedBox(width: 6),
              Text(_countdownText(reservation.expiresAt)),
            ],
          ),
          const SizedBox(height: 12),
          if (canCancel)
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: isCancelling ? null : onCancel,
                icon: const Icon(Icons.cancel, size: 18),
                label: const Text('Cancel'),
              ),
            ),
        ],
      ),
    );
  }

  String _countdownText(DateTime expiresAt) {
    final now = DateTime.now();
    final diff = expiresAt.difference(now);
    if (diff.isNegative) {
      return 'Expired';
    }
    final days = diff.inDays;
    final hours = diff.inHours.remainder(24);
    final minutes = diff.inMinutes.remainder(60);

    if (days > 0) {
      return 'Expires in ${days}d ${hours}h';
    }
    if (hours > 0) {
      return 'Expires in ${hours}h ${minutes}m';
    }
    return 'Expires in ${minutes}m';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
