import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../auth/providers/auth_provider.dart';
import '../provider/profile_provider.dart';
import 'add_journey_screen.dart';

class MyJourneysScreen extends StatelessWidget {
  const MyJourneysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final journeys = profileProvider.profile?.journeys ?? [];
    final token = context.read<AuthProvider>().token;
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddJourneyScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00CEA6), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: const Color(0xFF00CEA6).withOpacity(0.02),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Color(0xFF00CEA6)),
                  SizedBox(width: 8),
                  Text(
                    'Add Journey',
                    style: TextStyle(
                      color: Color(0xFF00CEA6),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: journeys.isEmpty
                ? const Center(
                    child: Text('No journeys yet', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: journeys.length,
                    itemBuilder: (context, index) {
                      final journey = journeys[index];
                      return _buildJourneyItem(context, journey, dateFormat, token);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyItem(BuildContext context, dynamic journey, DateFormat dateFormat, String? token) {
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
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: _buildCollageLayout(journey.media),
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
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.grey),
                      onPressed: () => _showJourneyOptions(context, journey.id, token),
                    ),
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
                if (journey.description != null && journey.description!.isNotEmpty)
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

  Widget _buildCollageLayout(List<dynamic> media) {
    if (media.isEmpty) {
      return Container(
        color: Colors.grey[100],
        child: const Center(
          child: Icon(Icons.image_outlined, color: Colors.grey, size: 40),
        ),
      );
    }

    if (media.length == 1) {
      return _buildNetworkImage(media[0].imageUrl);
    }

    if (media.length == 2) {
      return Row(
        children: [
          Expanded(child: _buildNetworkImage(media[0].imageUrl)),
          const SizedBox(width: 4),
          Expanded(child: _buildNetworkImage(media[1].imageUrl)),
        ],
      );
    }

    // 3 or more images: collage layout
    // Left: big image (flex 2)
    // Right: two smaller stacked images (flex 1)
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildNetworkImage(media[0].imageUrl),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: _buildNetworkImage(media[1].imageUrl),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _buildNetworkImage(media[2].imageUrl),
                    ),
                    if (media.length > 3)
                      Container(
                        color: Colors.black54,
                        child: Center(
                          child: Text(
                            '+${media.length - 3}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[50],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00CEA6)),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 24),
          ),
        );
      },
    );
  }

  void _showJourneyOptions(BuildContext context, int journeyId, String? token) {
    if (token == null) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete Journey', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, journeyId, token);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int journeyId, String token) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Journey'),
        content: const Text('Are you sure you want to delete this journey?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<ProfileProvider>().deleteJourney(journeyId, token);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Journey deleted successfully')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
