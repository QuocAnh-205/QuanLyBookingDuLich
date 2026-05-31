import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/detail_provider.dart';
import '../widgets/detail_error_view.dart';
import '../../../payment/presentation/screens/checkout_screen.dart';

class TourDetailScreen extends StatefulWidget {
  final int tourId;
  const TourDetailScreen({super.key, required this.tourId});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetailProvider>().fetchTourDetail(widget.tourId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
              // Image Gallery Carousel
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (tour.images.isNotEmpty)
                        PageView.builder(
                          itemCount: tour.images.length,
                          itemBuilder: (context, index) {
                            return Image.network(tour.images[index].url, fit: BoxFit.cover);
                          },
                        )
                      else
                        Image.network(tour.basicInfo.thumbnailUrl, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black45],
                          ),
                        ),
                      ),
                      // Image Indicator Mock
                      if (tour.images.isNotEmpty)
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '1/${tour.images.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              tour.basicInfo.title,
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Icon(Icons.favorite_border, color: Color(0xFF00CEA6), size: 30),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18, color: Color(0xFF00CEA6)),
                          Text(tour.basicInfo.locationName, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Provider Card
                      if (tour.provider != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(tour.provider!.logoUrl ?? 'https://i.pravatar.cc/150?u=provider'),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Organizer', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    Text(tour.provider!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(tour.provider!.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 30),
                      
                      // Quick Info Grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem(Icons.access_time, '${tour.basicInfo.durationDays} Days'),
                          _buildInfoItem(Icons.star, '4.8 (1.2k)'),
                          _buildInfoItem(Icons.language, 'English'),
                        ],
                      ),

                      const SizedBox(height: 30),
                      
                      // Pickup point
                      if (tour.pickupPoint != null) ...[
                        const Text('Pickup Point', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.directions_bus, size: 18, color: Color(0xFF00CEA6)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(tour.pickupPoint!, style: const TextStyle(color: Colors.black87))),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],

                      const Text('Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(
                        tour.basicInfo.description ?? 'No description available.',
                        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Detailed Itinerary
                      if (tour.schedules.isNotEmpty) ...[
                        const Text('Itinerary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        ...tour.schedules.map((s) => _buildItineraryItem('Day ${s.day}', '${s.time} - ${s.title}', s.description)),
                      ],

                      const SizedBox(height: 30),
                      
                      // Pricing breakdown
                      if (tour.agePricings.isNotEmpty) ...[
                        const Text('Pricing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ...tour.agePricings.map((p) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(p.label, style: const TextStyle(fontWeight: FontWeight.w500)),
                          trailing: Text('\$${p.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00CEA6))),
                        )),
                      ],
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: Consumer<DetailProvider>(
        builder: (context, provider, child) {
          final tour = provider.selectedTour;
          if (tour == null) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Base Price', style: TextStyle(color: Colors.grey)),
                    Text('\$${tour.basicInfo.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00CEA6),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                    child: const Text('Book Now', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00CEA6)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildItineraryItem(String day, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFF00CEA6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(day, style: const TextStyle(color: Color(0xFF00CEA6), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
