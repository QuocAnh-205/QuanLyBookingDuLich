import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/profile_provider.dart';

class MyJourneysScreen extends StatelessWidget {
  const MyJourneysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final journeys = profileProvider.profile?.journeys ?? [];
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Journeys',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00CEA6)),
            onPressed: () {
              // Mock create journey
            },
          ),
        ],
      ),
      body: journeys.isEmpty
          ? const Center(child: Text('No journeys yet', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: journeys.length,
              itemBuilder: (context, index) {
                final journey = journeys[index];
                return _buildJourneyItem(journey, dateFormat);
              },
            ),
    );
  }

  Widget _buildJourneyItem(dynamic journey, DateFormat dateFormat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: journey.media.isNotEmpty
                ? Image.network(
                    journey.media[0].imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        color: Colors.grey[100],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00CEA6))),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40)),
                      );
                    },
                  )
                : Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        journey.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.more_horiz, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Color(0xFF00CEA6)),
                    const SizedBox(width: 4),
                    Text(
                      journey.locationName ?? 'Unknown',
                      style: const TextStyle(color: Color(0xFF00CEA6), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (journey.description != null)
                  Text(
                    journey.description!,
                    style: TextStyle(color: Colors.grey[600], height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      journey.createdDate != null ? dateFormat.format(journey.createdDate!) : 'Recently',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 18, color: Color(0xFF00CEA6)),
                        const SizedBox(width: 4),
                        Text('${journey.likesCount} Likes', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
