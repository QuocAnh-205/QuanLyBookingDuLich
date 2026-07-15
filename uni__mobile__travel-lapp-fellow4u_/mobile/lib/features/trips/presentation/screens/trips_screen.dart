import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/trips/presentation/provider/trips_provider.dart';
import 'package:mobile/features/trips/presentation/widgets/trip_card.dart';
import 'package:mobile/features/trips/data/models/trip_models.dart';
import 'package:mobile/features/details/presentation/provider/wishlist_provider.dart';
import 'package:mobile/features/explore/presentation/widgets/tour_card.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/trips/presentation/screens/trip_detail_screen.dart';
import 'package:mobile/features/trips/presentation/screens/create_trip_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        context.read<TripsProvider>().fetchTrips(auth.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF00CEA6),
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'My Trips',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://ohdidi.vn/uploads/static/NEWS/blog/du%20lich%20da%20nang%20hoi%20an/du_lich_da_nang_hoi_an_2.png',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    isScrollable: true,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFF00CEA6),
                    ),
                    tabs: const [
                      Tab(
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Current Trips'))),
                      Tab(
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Next Trips'))),
                      Tab(
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Past Trips'))),
                      Tab(
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Wish List'))),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              const TripTabContent(type: 'current'),
              const TripTabContent(type: 'next'),
              const TripTabContent(type: 'past'),
              const WishlistTabContent(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateTripScreen()),
            );
          },
          backgroundColor: const Color(0xFF00CEA6),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height + 16;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 16;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class TripTabContent extends StatelessWidget {
  final String type;

  const TripTabContent({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripsProvider>(
      builder: (context, provider, child) {
        List<Trip> tripsToShow;
        switch (type) {
          case 'current':
            tripsToShow = provider.currentTrips;
            break;
          case 'next':
            tripsToShow = provider.nextTrips;
            break;
          case 'past':
            tripsToShow = provider.pastTrips;
            break;
          default:
            tripsToShow = [];
        }

        if (provider.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00CEA6)));
        }

        if (tripsToShow.isEmpty) {
          return _buildEmptyState(type);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tripsToShow.length,
          itemBuilder: (context, index) {
            final trip = tripsToShow[index];
            return TripCard(
              trip: trip,
              onChat: () => _showComingSoon(context, 'Chat'),
              onDetail: () {
                final auth = context.read<AuthProvider>();
                final tripsProvider = context.read<TripsProvider>();
                final token = auth.token;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripDetailScreen(tripId: trip.id),
                  ),
                ).then((_) {
                  // Refresh trips when returning from detail screen
                  if (token != null) {
                    tripsProvider.fetchTrips(token);
                  }
                });
              },
              onPay: () => _showComingSoon(context, 'Payment Checkout'),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String type) {
    IconData icon;
    String title;
    String subtitle;

    switch (type) {
      case 'current':
        icon = Icons.directions_run;
        title = 'No ongoing trips';
        subtitle = 'You are not on any trip right now.';
        break;
      case 'next':
        icon = Icons.event;
        title = 'No upcoming trips';
        subtitle = 'Plan your next adventure today!';
        break;
      case 'past':
        icon = Icons.history;
        title = 'No past trips';
        subtitle = 'Your travel history will appear here.';
        break;
      default:
        icon = Icons.card_travel;
        title = 'Empty';
        subtitle = '';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature functionality coming soon!')),
    );
  }
}

class WishlistTabContent extends StatefulWidget {
  const WishlistTabContent({super.key});

  @override
  State<WishlistTabContent> createState() => _WishlistTabContentState();
}

class _WishlistTabContentState extends State<WishlistTabContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        context.read<WishlistProvider>().fetchWishlist(auth.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00CEA6)));
        }

        if (provider.wishlistTours.isEmpty &&
            provider.wishlistExperiences.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Your wishlist is empty',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Start exploring and save your favorites!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.wishlistTours.length +
              provider.wishlistExperiences.length,
          itemBuilder: (context, index) {
            if (index < provider.wishlistTours.length) {
              final tour = provider.wishlistTours[index];
              return TourCard(
                tour: tour,
                isHorizontal: false,
                onTap: () {}, // Navigate to tour detail
              );
            } else {
              // Add Experience card if needed, or just tours for now
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}
