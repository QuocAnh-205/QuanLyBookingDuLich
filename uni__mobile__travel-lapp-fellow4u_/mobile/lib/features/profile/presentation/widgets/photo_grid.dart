import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';

class PhotoGrid extends StatelessWidget {
  const PhotoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final photos = profileProvider.profile?.photos ?? [];

    if (photos.isEmpty) {
      return const Center(child: Text('No photos yet'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            photos[index].imageUrl,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
