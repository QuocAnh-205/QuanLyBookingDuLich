import 'package:flutter/material.dart';
import '../../data/models/explore_models.dart';

class NewsItem extends StatelessWidget {
  final TravelNews news;
  final VoidCallback? onTap;

  const NewsItem({
    super.key,
    required this.news,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Feb 5, 2020', // Static or format from publishedAt
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                news.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
