import 'package:mobile/features/explore/data/models/explore_models.dart';

class BannerModel {
  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['banner_id'],
      title: json['title_text'],
      subtitle: json['subtitle_text'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}

class CollectionDetail {
  final int id;
  final String name;
  final String description;
  final List<Tour> tours;
  final List<Guide> guides;

  CollectionDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.tours,
    required this.guides,
  });

  factory CollectionDetail.fromJson(Map<String, dynamic> json) {
    return CollectionDetail(
      id: json['collection_id'],
      name: json['name'],
      description: json['description'] ?? '',
      tours: (json['Tours'] as List? ?? []).map((e) => Tour.fromJson(e)).toList(),
      guides: (json['Guides'] as List? ?? []).map((e) => Guide.fromJson(e)).toList(),
    );
  }
}
