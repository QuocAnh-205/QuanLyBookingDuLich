import '../../../explore/data/models/explore_models.dart';

class GuidePricing {
  final int minTravelers;
  final int maxTravelers;
  final double pricePerHour;

  GuidePricing({
    required this.minTravelers,
    required this.maxTravelers,
    required this.pricePerHour,
  });

  factory GuidePricing.fromJson(Map<String, dynamic> json) {
    return GuidePricing(
      minTravelers: json['min_travelers'],
      maxTravelers: json['max_travelers'],
      pricePerHour: double.parse(json['price_per_hour'].toString()),
    );
  }
}

class ReviewModel {
  final int id;
  final String authorName;
  final String authorAvatar;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final author = json['Author'];
    return ReviewModel(
      id: json['review_id'],
      authorName: author != null ? '${author['first_name']} ${author['last_name']}' : 'Anonymous',
      authorAvatar: author?['avatar_url'] ?? '',
      rating: json['rating'],
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class PortfolioMedia {
  final String url;
  final String type; // 'image' or 'video'
  final String title;

  PortfolioMedia({
    required this.url,
    required this.type,
    required this.title,
  });

  factory PortfolioMedia.fromJson(Map<String, dynamic> json) {
    return PortfolioMedia(
      url: json['media_url'],
      type: json['media_type'],
      title: json['title'] ?? '',
    );
  }
}

class LanguageModel {
  final String name;
  final String code;

  LanguageModel({required this.name, required this.code});

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      name: json['lang_name'],
      code: json['lang_code'],
    );
  }
}

class GuideFullProfile {
  final Guide basicInfo;
  final String bio;
  final String coverUrl;
  final List<LanguageModel> languages;
  final List<GuidePricing> pricings;
  final List<ReviewModel> reviews;
  final List<PortfolioMedia> portfolio;

  GuideFullProfile({
    required this.basicInfo,
    required this.bio,
    required this.coverUrl,
    required this.languages,
    required this.pricings,
    required this.reviews,
    required this.portfolio,
  });

  factory GuideFullProfile.fromJson(Map<String, dynamic> json) {
    final user = json['User'];
    return GuideFullProfile(
      basicInfo: Guide.fromJson(json),
      bio: user?['bio'] ?? '',
      coverUrl: user?['cover_url'] ?? '',
      languages: (json['Languages'] as List? ?? [])
          .map((item) => LanguageModel.fromJson(item))
          .toList(),
      pricings: (json['Pricings'] as List? ?? [])
          .map((item) => GuidePricing.fromJson(item))
          .toList(),
      reviews: (json['Reviews'] as List? ?? [])
          .map((item) => ReviewModel.fromJson(item))
          .toList(),
      portfolio: (json['Portfolio'] as List? ?? [])
          .map((item) => PortfolioMedia.fromJson(item))
          .toList(),
    );
  }
}

class Attraction {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String address;

  Attraction({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.address,
  });

  factory Attraction.fromJson(Map<String, dynamic> json) {
    return Attraction(
      id: json['attraction_id'],
      name: json['name'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class ProviderModel {
  final String name;
  final String? logoUrl;
  final double rating;

  ProviderModel({required this.name, this.logoUrl, required this.rating});

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      name: json['name'],
      logoUrl: json['logo_url'],
      rating: double.parse((json['rating_avg'] ?? 0.0).toString()),
    );
  }
}

class TourImageModel {
  final String url;
  final String? caption;

  TourImageModel({required this.url, this.caption});

  factory TourImageModel.fromJson(Map<String, dynamic> json) {
    return TourImageModel(
      url: json['image_url'],
      caption: json['caption'],
    );
  }
}

class TourScheduleModel {
  final int day;
  final String time;
  final String title;
  final String description;
  final Attraction? attraction;

  TourScheduleModel({
    required this.day,
    required this.time,
    required this.title,
    required this.description,
    this.attraction,
  });

  factory TourScheduleModel.fromJson(Map<String, dynamic> json) {
    return TourScheduleModel(
      day: json['day_number'],
      time: json['start_time'].toString().substring(0, 5),
      title: json['activity_title'],
      description: json['description'] ?? '',
      attraction: json['Attraction'] != null ? Attraction.fromJson(json['Attraction']) : null,
    );
  }
}

class AgePricingModel {
  final String label;
  final double price;

  AgePricingModel({required this.label, required this.price});

  factory AgePricingModel.fromJson(Map<String, dynamic> json) {
    return AgePricingModel(
      label: json['age_group_label'],
      price: double.parse(json['price'].toString()),
    );
  }
}

class TourDetailFull {
  final Tour basicInfo;
  final ProviderModel? provider;
  final String? pickupPoint;
  final List<TourImageModel> images;
  final List<TourScheduleModel> schedules;
  final List<AgePricingModel> agePricings;

  TourDetailFull({
    required this.basicInfo,
    this.provider,
    this.pickupPoint,
    required this.images,
    required this.schedules,
    required this.agePricings,
  });

  factory TourDetailFull.fromJson(Map<String, dynamic> json) {
    return TourDetailFull(
      basicInfo: Tour.fromJson(json),
      provider: json['Provider'] != null ? ProviderModel.fromJson(json['Provider']) : null,
      pickupPoint: json['pickup_point'],
      images: (json['Images'] as List? ?? [])
          .map((item) => TourImageModel.fromJson(item))
          .toList(),
      schedules: (json['Schedules'] as List? ?? [])
          .map((item) => TourScheduleModel.fromJson(item))
          .toList(),
      agePricings: (json['AgePricings'] as List? ?? [])
          .map((item) => AgePricingModel.fromJson(item))
          .toList(),
    );
  }
}

class LocationFullDetail {
  final Location basicInfo;
  final String description;
  final List<Attraction> attractions;
  final List<Tour> suggestedTours;
  final List<Experience> suggestedExperiences;

  LocationFullDetail({
    required this.basicInfo,
    required this.description,
    required this.attractions,
    required this.suggestedTours,
    required this.suggestedExperiences,
  });

  factory LocationFullDetail.fromJson(Map<String, dynamic> json) {
    return LocationFullDetail(
      basicInfo: Location.fromJson(json),
      description: json['description'] ?? '',
      attractions: (json['Attractions'] as List? ?? [])
          .map((item) => Attraction.fromJson(item))
          .toList(),
      suggestedTours: (json['Tours'] as List? ?? [])
          .map((item) => Tour.fromJson(item))
          .toList(),
      suggestedExperiences: (json['Experiences'] as List? ?? [])
          .map((item) => Experience.fromJson(item))
          .toList(),
    );
  }
}
