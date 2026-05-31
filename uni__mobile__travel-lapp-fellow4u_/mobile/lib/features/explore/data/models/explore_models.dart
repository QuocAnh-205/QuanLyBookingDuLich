class Location {
  final int id;
  final String name;
  final String thumbnailUrl;
  final bool isPopular;

  Location({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    this.isPopular = false,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['location_id'],
      name: json['city_name'],
      thumbnailUrl: json['thumbnail_url'] ?? '',
      isPopular: json['is_popular'] ?? false,
    );
  }
}

class Tour {
  final int id;
  final String title;
  final double price;
  final int durationDays;
  final String thumbnailUrl;
  final String locationName;
  final String? description;
  final bool isFeatured;

  Tour({
    required this.id,
    required this.title,
    required this.price,
    required this.durationDays,
    required this.thumbnailUrl,
    required this.locationName,
    this.description,
    this.isFeatured = false,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['tour_id'],
      title: json['title'],
      price: double.parse(json['price'].toString()),
      durationDays: json['duration_days'] ?? 1,
      thumbnailUrl: json['thumbnail_url'] ?? '',
      locationName: json['Location']?['city_name'] ?? '',
      description: json['description'],
      isFeatured: json['is_featured'] ?? false,
    );
  }
}

class Guide {
  final int id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int totalReviews;
  final String locationName;

  Guide({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.totalReviews,
    required this.locationName,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    final user = json['User'];
    return Guide(
      id: json['guide_id'],
      name: user != null ? '${user['first_name']} ${user['last_name']}' : 'Unknown',
      avatarUrl: user?['avatar_url'] ?? '',
      rating: double.parse(json['rating_avg'].toString()),
      totalReviews: json['total_reviews'] ?? 0,
      locationName: json['BaseLocation']?['city_name'] ?? '',
    );
  }
}

class Experience {
  final int id;
  final String title;
  final double price;
  final double durationHours;
  final String thumbnailUrl;
  final String guideName;
  final String guideAvatarUrl;
  final String locationName;

  Experience({
    required this.id,
    required this.title,
    required this.price,
    required this.durationHours,
    required this.thumbnailUrl,
    required this.guideName,
    required this.guideAvatarUrl,
    required this.locationName,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    final guideUser = json['GuideProfile']?['User'];
    return Experience(
      id: json['exp_id'],
      title: json['title'],
      price: double.parse(json['price'].toString()),
      durationHours: double.parse(json['duration_hours'].toString()),
      thumbnailUrl: json['thumbnail_url'] ?? '',
      guideName: guideUser != null ? '${guideUser['first_name']} ${guideUser['last_name']}' : 'Unknown',
      guideAvatarUrl: guideUser?['avatar_url'] ?? 'https://i.pravatar.cc/150?u=guide',
      locationName: json['Location']?['city_name'] ?? '',
    );
  }
}

class TravelNews {
  final int id;
  final String title;
  final String imageUrl;
  final String contentSnippet;
  final DateTime publishedAt;

  TravelNews({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.contentSnippet,
    required this.publishedAt,
  });

  factory TravelNews.fromJson(Map<String, dynamic> json) {
    return TravelNews(
      id: json['news_id'],
      title: json['title'],
      imageUrl: json['image_url'] ?? '',
      contentSnippet: json['content'] ?? '',
      publishedAt: DateTime.parse(json['published_at']),
    );
  }
}
