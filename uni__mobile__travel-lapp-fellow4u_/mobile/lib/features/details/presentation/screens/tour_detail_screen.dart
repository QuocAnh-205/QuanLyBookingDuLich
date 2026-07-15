import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/detail_provider.dart';
import '../widgets/detail_error_view.dart';
import '../../../payment/presentation/screens/checkout_screen.dart';
import '../../data/models/detail_models.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/details/presentation/provider/wishlist_provider.dart';

class TourDetailScreen extends StatefulWidget {
  final int tourId;
  const TourDetailScreen({super.key, required this.tourId});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  int _selectedDay = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetailProvider>().fetchTourDetail(widget.tourId);
    });
  }

  void _showSharePopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Share on',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialBtn(
                      'Facebook', Icons.facebook, const Color(0xFF3B5998)),
                  _buildSocialBtn(
                      'Google', Icons.g_mobiledata, const Color(0xFFEA4335)),
                  _buildSocialBtn(
                      'Kakao Talk', Icons.chat_bubble, const Color(0xFFFFEB3B),
                      iconColor: Colors.black87),
                  _buildSocialBtn(
                      'WhatsApp', Icons.phone_android, const Color(0xFF25D366)),
                  _buildSocialBtn(
                      'Twitter', Icons.chat, const Color(0xFF1DA1F2)),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: Color(0xFF00CEA6), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF00CEA6),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSocialBtn(String label, IconData icon, Color bgColor,
      {Color iconColor = Colors.white}) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00CEA6)));
          }
          if (provider.error != null) {
            return DetailErrorView(
              message: provider.error!,
              onRetry: () => provider.fetchTourDetail(widget.tourId),
            );
          }
          final tour = provider.selectedTour;
          if (tour == null) return const SizedBox.shrink();

          return CustomScrollView(
            slivers: [
              // Custom Image Gallery Carousel
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white),
                    onPressed: () => _showSharePopup(context),
                  ),
                  Consumer2<AuthProvider, WishlistProvider>(
                    builder: (context, auth, wishlist, _) {
                      final isFav = wishlist.isFavorite(tour.basicInfo.id, isTour: true);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.white,
                        ),
                        onPressed: () {
                          if (auth.token != null) {
                            wishlist.toggleWishlist(auth.token!, tourId: tour.basicInfo.id);
                          }
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.bookmark_border, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (tour.images.isNotEmpty)
                        PageView.builder(
                          itemCount: tour.images.length,
                          itemBuilder: (context, index) {
                            return Image.network(tour.images[index].url,
                                fit: BoxFit.cover);
                          },
                        )
                      else
                        Image.network(tour.basicInfo.thumbnailUrl,
                            fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black26,
                              Colors.transparent,
                              Colors.black45
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tour Header info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tour.basicInfo.title,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.star,
                                            color: Colors.amber, size: 16),
                                        Icon(Icons.star,
                                            color: Colors.amber, size: 16),
                                        Icon(Icons.star,
                                            color: Colors.amber, size: 16),
                                        Icon(Icons.star,
                                            color: Colors.amber, size: 16),
                                        Icon(Icons.star,
                                            color: Colors.amber, size: 16),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${tour.provider?.rating ?? 4.8} (145 Reviews)',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${tour.basicInfo.price.toStringAsFixed(0)}.00',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00CEA6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${(tour.basicInfo.price * 1.2).toStringAsFixed(0)}.00',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Provider',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(width: 8),
                          Text(
                            tour.provider?.name ?? 'dulichviet',
                            style: const TextStyle(
                              color: Color(0xFF00CEA6),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Summary box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Summary',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryItem(
                                'Itinerary', tour.basicInfo.title),
                            _buildSummaryItem('Duration',
                                '${tour.basicInfo.durationDays} days, ${tour.basicInfo.durationDays} nights'),
                            _buildSummaryItem('Departure Date', 'Feb 12'),
                            _buildSummaryItem('Departure Place',
                                tour.pickupPoint ?? 'Ho Chi Minh'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Schedule Section
                      const Text(
                        'Schedule',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Tabs for Days
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            tour.basicInfo.durationDays,
                            (index) {
                              final day = index + 1;
                              final isSelected = _selectedDay == day;
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: ChoiceChip(
                                  showCheckmark: false,
                                  label: Text(
                                    'Day $day',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF00CEA6),
                                  backgroundColor: Colors.grey[100],
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedDay = day;
                                      });
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Schedule list for selected day
                      ...tour.schedules
                          .where((s) => s.day == _selectedDay)
                          .map((s) => _buildScheduleItem(s)),

                      if (tour.schedules
                          .where((s) => s.day == _selectedDay)
                          .isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('No schedule details for this day.',
                              style: TextStyle(color: Colors.grey)),
                        ),

                      const SizedBox(height: 24),

                      // Price Table
                      const Text(
                        'Price',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Table(
                        border: TableBorder.all(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(8)),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                        },
                        children: tour.agePricings.isNotEmpty
                            ? tour.agePricings.map((p) {
                                final displayPrice = p.price == 0
                                    ? 'Free'
                                    : '\$${p.price.toStringAsFixed(0)}.00';
                                return _buildTableRow(p.label, displayPrice);
                              }).toList()
                            : [
                                _buildTableRow(
                                    'Adult (>10 years old)', '\$400.00'),
                                _buildTableRow(
                                    'Child (5 - 10 years old)', '\$320.00'),
                                _buildTableRow('Child (<5 years old)', 'Free'),
                              ],
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<DetailProvider>(
        builder: (context, provider, child) {
          final tour = provider.selectedTour;
          if (tour == null) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00CEA6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(
                          tourId: tour.basicInfo.id,
                          tourTitle: tour.basicInfo.title,
                          tourPrice: tour.basicInfo.price,
                          durationDays: tour.basicInfo.durationDays,
                          locationName: tour.basicInfo.locationName,
                          thumbnailUrl: tour.basicInfo.thumbnailUrl,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'BOOK THIS TOUR',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(TourScheduleModel schedule) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF00CEA6), width: 3),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: const Color(0xFF00CEA6).withOpacity(0.3),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.time,
                  style: const TextStyle(
                    color: Color(0xFF00CEA6),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
