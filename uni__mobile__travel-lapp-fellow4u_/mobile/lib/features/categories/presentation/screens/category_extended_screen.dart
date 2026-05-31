import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../explore/presentation/widgets/tour_card.dart';
import '../../../explore/presentation/widgets/guide_card.dart';
import '../../../details/presentation/screens/tour_detail_screen.dart';
import '../../../details/presentation/screens/guide_detail_screen.dart';
import '../provider/category_provider.dart';

class CategoryExtendedScreen extends StatefulWidget {
  final String pageType; // 'Guides_More' or 'Tours_More'
  final String collectionSlug;

  const CategoryExtendedScreen({
    super.key,
    required this.pageType,
    required this.collectionSlug,
  });

  @override
  State<CategoryExtendedScreen> createState() => _CategoryExtendedScreenState();
}

class _CategoryExtendedScreenState extends State<CategoryExtendedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchExtendedView(widget.pageType, widget.collectionSlug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00CEA6)));
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          final banner = provider.activeBanner;
          final collection = provider.currentCollection;

          if (collection == null) return const SizedBox.shrink();

          return CustomScrollView(
            slivers: [
              // Dynamic Header Banner
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: const Color(0xFF00CEA6),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    banner?.title ?? collection.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (banner != null)
                        Image.network(banner.imageUrl, fit: BoxFit.cover)
                      else
                        Container(color: const Color(0xFF00CEA6)),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 60,
                        right: 20,
                        child: Text(
                          banner?.subtitle ?? collection.description,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content List
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: widget.pageType == 'Tours_More'
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final tour = collection.tours[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: TourCard(
                                tour: tour,
                                isHorizontal: false,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => TourDetailScreen(tourId: tour.id)),
                                ),
                              ),
                            );
                          },
                          childCount: collection.tours.length,
                        ),
                      )
                    : SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final guide = collection.guides[index];
                            return GuideCard(
                              guide: guide,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => GuideDetailScreen(guideId: guide.id)),
                              ),
                            );
                          },
                          childCount: collection.guides.length,
                        ),
                      ),
              ),
              
              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          );
        },
      ),
    );
  }
}
