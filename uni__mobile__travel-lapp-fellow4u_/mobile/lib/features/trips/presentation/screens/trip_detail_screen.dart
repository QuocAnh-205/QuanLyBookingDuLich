import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/trip_models.dart';
import '../provider/trips_provider.dart';
import '../widgets/trip_status_badge.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import '../../../chat/presentation/provider/chat_provider.dart';
import '../../../chat/presentation/screens/chat_detail_screen.dart';
import 'payment_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final int tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<TripsProvider>().fetchTripDetail(widget.tripId, token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<TripsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00CEA6)));
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final token = context.read<AuthProvider>().token;
                      if (token != null) {
                        provider.fetchTripDetail(widget.tripId, token);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final trip = provider.selectedTrip;
          if (trip == null) {
            return const Center(child: Text('Trip not found'));
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(trip),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(trip),
                      const SizedBox(height: 24),
                      _buildKeyDetails(trip),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Meeting Point'),
                      _buildLocationCard(trip),
                      const SizedBox(height: 24),
                      if (trip.specialRequests != null && trip.specialRequests!.isNotEmpty) ...[
                        _buildSectionTitle('Special Requests'),
                        _buildRequestCard(trip),
                        const SizedBox(height: 24),
                      ],
                      if (trip.status == TripStatus.bidding) ...[
                        _buildSectionTitle('Bids from Guides'),
                        _buildBidsList(trip, provider),
                        const SizedBox(height: 24),
                      ],
                      _buildSectionTitle('Status History'),
                      _buildStatusTimeline(trip),
                      const SizedBox(height: 100), // Bottom padding for buttons
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: _buildBottomActions(),
    );
  }

  Widget _buildAppBar(Trip trip) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: const Color(0xFF00CEA6),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
              Hero(
                tag: 'trip_image_${trip.id}',
                child: Image.network(
                  trip.tour?.thumbnailUrl ?? 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=2070&auto=format&fit=crop',
                  fit: BoxFit.cover,
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeader(Trip trip) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.tour?.title ?? 'Custom Trip Request',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TripStatusBadge(status: trip.status),
            ],
          ),
        ),
        if (trip.guide != null)
          Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(trip.guide!.avatarUrl),
              ),
              const SizedBox(height: 4),
              Text(
                trip.guide!.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildKeyDetails(Trip trip) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          _buildDetailItem(Icons.calendar_today, 'Date', dateFormat.format(trip.startDate)),
          const Divider(height: 24),
          _buildDetailItem(Icons.access_time, 'Time', '${timeFormat.format(trip.startDate)} - ${timeFormat.format(trip.endDate)}'),
          const Divider(height: 24),
          _buildDetailItem(Icons.monetization_on_outlined, 'Total Price', '\$${trip.totalPrice.toStringAsFixed(2)}'),
          const Divider(height: 24),
          _buildDetailItem(Icons.account_balance_wallet_outlined, 'Deposit', '\$${trip.depositAmount.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00CEA6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF00CEA6), size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLocationCard(Trip trip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              trip.meetingPoint ?? 'To be discussed',
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Trip trip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Text(
        trip.specialRequests ?? '',
        style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildBidsList(Trip trip, TripsProvider provider) {
    if (trip.bids.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No bids yet. Please wait for guides to offer.'),
        ),
      );
    }

    return Column(
      children: trip.bids.map((bid) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(bid.guide.avatarUrl),
          ),
          title: Text(bid.guide.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Offered: \$${bid.offeredPrice}'),
              if (bid.message != null) Text(bid.message!, style: const TextStyle(fontSize: 12)),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: () => _handleSelectBid(trip.id, bid.id, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00CEA6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Accept'),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildStatusTimeline(Trip trip) {
    return Column(
      children: trip.statusHistory.map((history) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00CEA6),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2,
                  height: 40,
                  color: const Color(0xFF00CEA6).withOpacity(0.3),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM dd, HH:mm').format(history.changedAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    'Status changed to ${history.toStatus.name.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (history.reason != null)
                    Text(
                      history.reason!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget? _buildBottomActions() {
    final provider = context.watch<TripsProvider>();
    final trip = provider.selectedTrip;
    if (trip == null) return null;

    if (trip.status == TripStatus.ongoing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _handleUpdateStatus(trip.id, 'completed', provider),
              icon: const Icon(Icons.check, color: Colors.black),
              label: const Text('Mark Finished', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      );
    }

    if (trip.status == TripStatus.unpaid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleChat(),
                  icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF00CEA6)),
                  label: const Text('Chat', style: TextStyle(color: Color(0xFF00CEA6), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF00CEA6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handlePayment(trip),
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: const Text('Pay', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00CEA6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _handleChat(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF00CEA6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Chat with Guide', style: TextStyle(color: Color(0xFF00CEA6), fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMainActionButton(trip, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActionButton(Trip trip, TripsProvider provider) {
    String text = 'Contact Support';
    VoidCallback? onPressed;
    Color color = const Color(0xFF00CEA6);

    switch (trip.status) {
      case TripStatus.unpaid:
        text = 'Pay Now';
        onPressed = () => _handlePayment(trip);
        break;
      case TripStatus.paid:
        text = 'View Voucher';
        onPressed = () {};
        break;
      case TripStatus.ongoing:
        text = 'Complete Trip';
        onPressed = () => _handleUpdateStatus(trip.id, 'completed', provider);
        break;
      case TripStatus.completed:
        text = 'Leave Review';
        onPressed = () {};
        break;
      default:
        text = 'Cancel Trip';
        color = Colors.red;
        onPressed = () => _handleUpdateStatus(trip.id, 'cancelled', provider);
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // Handlers
  void _handleSelectBid(int bookingId, int bidId, TripsProvider provider) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final success = await provider.selectBid(bookingId, bidId, token);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bid selected successfully!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? 'Failed to select bid')));
    }
  }

  void _handleUpdateStatus(int id, String status, TripsProvider provider) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final success = await provider.updateStatus(id, status, token);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Trip status updated to $status')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? 'Failed to update status')));
    }
  }

  void _handleChat() async {
    final trip = context.read<TripsProvider>().selectedTrip;
    if (trip == null) return;

    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final chatProvider = context.read<ChatProvider>();
    final room = await chatProvider.startChat(trip.id, token);

    if (room != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(roomId: room.id),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(chatProvider.error ?? 'Could not start chat')),
      );
    }
  }

  void _handlePayment(Trip trip) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentScreen(trip: trip)),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thanks! Check out successfully. Enjoy your trip!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF81C784), // Lighter green matching UI
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150, left: 16, right: 16),
        ),
      );
      Navigator.pop(context);
    }
  }
}
