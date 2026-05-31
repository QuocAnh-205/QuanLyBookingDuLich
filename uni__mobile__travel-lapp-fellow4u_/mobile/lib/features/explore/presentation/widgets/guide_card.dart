import 'package:flutter/material.dart';
import '../../data/models/explore_models.dart';

class GuideCard extends StatelessWidget {
  final Guide guide;
  final VoidCallback? onTap;

  const GuideCard({
    super.key,
    required this.guide,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    guide.avatarUrl.isNotEmpty ? guide.avatarUrl : 'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) => const Icon(Icons.star, size: 12, color: Colors.amber)),
                      ),
                      Text(
                        '${guide.totalReviews} Reviews',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            guide.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: Color(0xFF00CEA6)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  guide.locationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
