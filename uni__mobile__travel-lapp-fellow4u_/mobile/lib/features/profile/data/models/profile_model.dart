enum Gender { male, female, other }
enum ThemeModeType { light, dark, system }

class UserSetting {
  final String preferredLanguage;
  final String preferredCurrency;
  final bool enablePushNotifications;
  final bool enableEmailNotifications;
  final ThemeModeType themeMode;

  UserSetting({
    this.preferredLanguage = 'en',
    this.preferredCurrency = 'USD',
    this.enablePushNotifications = true,
    this.enableEmailNotifications = true,
    this.themeMode = ThemeModeType.light,
  });

  factory UserSetting.fromJson(Map<String, dynamic> json) {
    return UserSetting(
      preferredLanguage: json['preferred_language'] ?? 'en',
      preferredCurrency: json['preferred_currency'] ?? 'USD',
      enablePushNotifications: json['enable_push_notifications'] ?? true,
      enableEmailNotifications: json['enable_email_notifications'] ?? true,
      themeMode: ThemeModeType.values.firstWhere(
        (e) => e.name == (json['theme_mode'] ?? 'light'),
        orElse: () => ThemeModeType.light,
      ),
    );
  }
}

class UserPhoto {
  final int id;
  final String imageUrl;
  final bool isPublic;
  final DateTime? uploadedAt;

  UserPhoto({
    required this.id,
    required this.imageUrl,
    this.isPublic = true,
    this.uploadedAt,
  });

  factory UserPhoto.fromJson(Map<String, dynamic> json) {
    return UserPhoto(
      id: json['photo_id'],
      imageUrl: json['image_url'],
      isPublic: json['is_public'] ?? true,
      uploadedAt: json['uploaded_at'] != null ? DateTime.parse(json['uploaded_at']) : null,
    );
  }
}

class UserJourney {
  final int id;
  final String title;
  final String? locationName;
  final String? description;
  final int likesCount;
  final DateTime? createdDate;
  final List<UserPhoto> media;

  UserJourney({
    required this.id,
    required this.title,
    this.locationName,
    this.description,
    this.likesCount = 0,
    this.createdDate,
    this.media = const [],
  });

  factory UserJourney.fromJson(Map<String, dynamic> json) {
    return UserJourney(
      id: json['journey_id'],
      title: json['title'],
      locationName: json['location_name'],
      description: json['description'],
      likesCount: json['likes_count'] ?? 0,
      createdDate: json['created_date'] != null ? DateTime.parse(json['created_date']) : null,
      media: (json['Media'] as List?)?.map((m) => UserPhoto.fromJson(m)).toList() ?? [],
    );
  }
}

class UserProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? avatarUrl;
  final String? coverUrl;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final UserSetting? settings;
  final List<UserPhoto> photos;
  final List<UserJourney> journeys;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.coverUrl,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.settings,
    this.photos = const [],
    this.journeys = const [],
  });

  String get fullName => '$firstName $lastName';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      role: json['role'] ?? 'Traveler',
      avatarUrl: json['avatar_url'],
      coverUrl: json['cover_url'],
      bio: json['bio'],
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
      gender: json['gender'],
      settings: json['Settings'] != null ? UserSetting.fromJson(json['Settings']) : null,
      photos: (json['Photos'] as List?)?.map((p) => UserPhoto.fromJson(p)).toList() ?? [],
      journeys: (json['Journeys'] as List?)?.map((j) => UserJourney.fromJson(j)).toList() ?? [],
    );
  }
}
