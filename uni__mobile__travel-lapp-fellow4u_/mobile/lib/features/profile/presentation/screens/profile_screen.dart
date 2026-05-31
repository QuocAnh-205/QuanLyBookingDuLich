import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../provider/profile_provider.dart';
import '../widgets/profile_header.dart';
import 'package:intl/intl.dart';
import 'my_photos_screen.dart';
import 'my_journeys_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<ProfileProvider>().fetchProfile(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final user = profileProvider.profile;
    final isLoading = profileProvider.isLoading;

    if (isLoading && user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00CEA6))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          final token = context.read<AuthProvider>().token;
          if (token != null) {
            await context.read<ProfileProvider>().fetchProfile(token);
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileHeader(),
              _buildSectionHeader('My Photos', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPhotosScreen()));
              }),
              _buildPhotosGrid(user?.photos ?? []),
              const SizedBox(height: 24),
              _buildSectionHeader('My Journeys', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyJourneysScreen()));
              }),
              _buildJourneysList(user?.journeys ?? []),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.keyboard_double_arrow_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosGrid(List<dynamic> photos) {
    if (photos.isEmpty) return const SizedBox.shrink();
    
    // Layout like design: 3 small in a row, 1 large below
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildPhoto(photos[0].imageUrl)),
              const SizedBox(width: 8),
              Expanded(child: _buildPhoto(photos.length > 1 ? photos[1].imageUrl : photos[0].imageUrl)),
              const SizedBox(width: 8),
              Expanded(child: _buildPhoto(photos.length > 2 ? photos[2].imageUrl : photos[0].imageUrl)),
            ],
          ),
          const SizedBox(height: 8),
          if (photos.length > 3)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: _buildNetworkImage(photos[3].imageUrl),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[100],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00CEA6)),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildPhoto(String url) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildNetworkImage(url),
      ),
    );
  }

  Widget _buildJourneysList(List<dynamic> journeys) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: journeys.length,
      itemBuilder: (context, index) {
        final journey = journeys[index];
        return _buildJourneyCard(journey);
      },
    );
  }

  Widget _buildJourneyCard(dynamic journey) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Split Image Layout
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 200,
              child: Row(
                children: [
                Expanded(
                  flex: 2,
                  child: _buildNetworkImage(
                    journey.media.isNotEmpty ? journey.media[0].imageUrl : 'https://via.placeholder.com/200',
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildNetworkImage(
                          journey.media.length > 1 ? journey.media[1].imageUrl : 'https://via.placeholder.com/100',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Expanded(
                        child: _buildNetworkImage(
                          journey.media.length > 2 ? journey.media[2].imageUrl : 'https://via.placeholder.com/100',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      journey.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      style: const TextStyle(color: Color(0xFF00CEA6), fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      journey.createdDate != null ? dateFormat.format(journey.createdDate!) : 'Jan 20, 2020',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    Row(
                      children: [
                        Icon(Icons.favorite_border, size: 18, color: const Color(0xFF00CEA6).withOpacity(0.5)),
                        const SizedBox(width: 4),
                        const Text('234 Likes', style: TextStyle(color: Colors.grey, fontSize: 13)),
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
