import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';

class JourneyList extends StatelessWidget {
  const JourneyList({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final journeys = profileProvider.profile?.journeys ?? [];
    final dateFormat = DateFormat('MMM dd, yyyy');

    if (journeys.isEmpty) {
      return const Center(child: Text('No journeys yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: journeys.length,
      itemBuilder: (context, index) {
        final journey = journeys[index];
        final imageUrl = journey.media.isNotEmpty 
            ? journey.media.first.imageUrl 
            : 'https://via.placeholder.com/400x150';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journey.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          journey.locationName ?? 'Unknown Location',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const Spacer(),
                        Text(
                          journey.createdDate != null 
                              ? dateFormat.format(journey.createdDate!)
                              : 'No date',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
