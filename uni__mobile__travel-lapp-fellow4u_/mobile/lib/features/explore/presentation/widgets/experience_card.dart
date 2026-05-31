import 'package:flutter/material.dart';
import 'package:mobile/features/explore/data/models/explore_models.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/details/presentation/provider/wishlist_provider.dart';

class ExperienceCard extends StatelessWidget {
  final Experience experience;
  final VoidCallback? onTap;

  const ExperienceCard({
    super.key,
    required this.experience,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      experience.thumbnailUrl,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 36)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Consumer2<AuthProvider, WishlistProvider>(
                      builder: (context, auth, wishlist, _) => GestureDetector(
                        onTap: () {
                          if (auth.token != null) {
                            wishlist.toggleWishlist(auth.token!, expId: experience.id);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white70,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            wishlist.isFavorite(experience.id, isTour: false) ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: wishlist.isFavorite(experience.id, isTour: false) ? Colors.red : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00CEA6),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(experience.guideAvatarUrl),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00CEA6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            experience.guideName,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              experience.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: Color(0xFF00CEA6)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    experience.locationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
