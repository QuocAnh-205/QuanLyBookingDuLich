import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/explore/presentation/provider/explore_provider.dart';
import 'package:mobile/features/explore/presentation/widgets/section_header.dart';
import 'package:mobile/features/explore/presentation/widgets/custom_search_bar.dart';
import 'package:mobile/features/explore/presentation/widgets/location_chip.dart';
import 'package:mobile/features/explore/presentation/widgets/tour_card.dart';
import 'package:mobile/features/explore/presentation/widgets/guide_card.dart';
import 'package:mobile/features/explore/presentation/widgets/experience_card.dart';
import 'package:mobile/features/explore/presentation/widgets/news_item.dart';
import 'package:mobile/features/details/presentation/screens/tour_detail_screen.dart';
import 'package:mobile/features/details/presentation/screens/guide_detail_screen.dart';
import 'package:mobile/features/details/presentation/screens/destination_detail_screen.dart';
import 'package:mobile/features/categories/presentation/screens/category_extended_screen.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/details/presentation/provider/wishlist_provider.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<WishlistProvider>().fetchWishlist(token);
      }
    });
    return Scaffold(
      body: Consumer<ExploreProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00CEA6)));
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => provider.fetchExploreData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchExploreData(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Background Image and Overlays
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 280,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage('https://images2.thanhnien.vn/528068263637045248/2025/6/18/the-legend-danang-1-17502421275011965589401.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        height: 280,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                              Colors.black.withOpacity(0.2),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 60,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Explore',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.location_on, size: 18, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'Da Nang',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: const [
                                        Icon(Icons.cloud_queue, size: 24, color: Colors.white),
                                        SizedBox(width: 6),
                                        Text(
                                          '26°C',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 34,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        bottom: -30,
                        left: 0,
                        right: 0,
                        child: CustomSearchBar(readOnly: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 45),

                  // Top Journeys (Horizontal)
                  if (provider.featuredTours.isNotEmpty) ...[
                    const SectionHeader(title: 'Top Journeys'),
                    SizedBox(
                      height: 340,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.featuredTours.length,
                        itemBuilder: (context, index) {
                          final tour = provider.featuredTours[index];
                          return TourCard(
                            tour: tour, 
                            isHorizontal: true,
                            onTap: () => Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => TourDetailScreen(tourId: tour.id))
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Best Guides (Grid 2 columns)
                  if (provider.bestGuides.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Best Guides',
                      onSeeAll: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryExtendedScreen(
                            pageType: 'Guides_More',
                            collectionSlug: 'best-guides',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: provider.bestGuides.length.clamp(0, 4),
                        itemBuilder: (context, index) {
                          final guide = provider.bestGuides[index];
                          return GuideCard(
                            guide: guide,
                            onTap: () => Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => GuideDetailScreen(guideId: guide.id))
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Top Experiences
                  if (provider.topExperiences.isNotEmpty) ...[
                    const SectionHeader(title: 'Top Experiences'),
                    SizedBox(
                      height: 240,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.topExperiences.length,
                        itemBuilder: (context, index) {
                          final exp = provider.topExperiences[index];
                          return ExperienceCard(
                            experience: exp,
                            onTap: () {
                              // TODO: Navigate to ExperienceDetailScreen when implemented
                              // Navigator.push(context, MaterialPageRoute(builder: (_) => ExperienceDetailScreen(expId: exp.id)));
                            },
                          );
                        },
                      ),
                    ),
                  ],

                  // Featured Tours (Vertical)
                  if (provider.featuredTours.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Featured Tours',
                      onSeeAll: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryExtendedScreen(
                            pageType: 'Tours_More',
                            collectionSlug: 'featured-tours',
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.featuredTours.length,
                      itemBuilder: (context, index) {
                        final tour = provider.featuredTours[index];
                        return TourCard(
                          tour: tour, 
                          isHorizontal: false,
                          onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => TourDetailScreen(tourId: tour.id))
                          ),
                        );
                      },
                    ),
                  ],

                  // Travel News
                  if (provider.travelNews.isNotEmpty) ...[
                    const SectionHeader(title: 'Travel News'),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.travelNews.length,
                      itemBuilder: (context, index) {
                        return NewsItem(news: provider.travelNews[index]);
                      },
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
