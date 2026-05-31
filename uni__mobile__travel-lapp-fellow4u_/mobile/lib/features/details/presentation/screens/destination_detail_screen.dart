import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/detail_provider.dart';
import '../../../explore/presentation/widgets/tour_card.dart';
import '../widgets/detail_error_view.dart';

class DestinationDetailScreen extends StatefulWidget {
  final int locationId;
  const DestinationDetailScreen({super.key, required this.locationId});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetailProvider>().fetchLocationDetail(widget.locationId);
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
              onRetry: () => provider.fetchLocationDetail(widget.locationId),
            );
          }
          final location = provider.selectedLocation;
          if (location == null) return const SizedBox.shrink();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(location.basicInfo.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  background: Image.network(location.basicInfo.thumbnailUrl, fit: BoxFit.cover),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(location.description, style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5)),
                      
                      const SizedBox(height: 30),
                      const Text('Top Attractions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      ...location.attractions.map((a) => Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(a.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 10),
                            Text(a.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(a.description, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )),

                      const SizedBox(height: 30),
                      const Text('Recommended Tours', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: location.suggestedTours.length,
                          itemBuilder: (context, index) {
                            return TourCard(tour: location.suggestedTours[index], isHorizontal: true);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
