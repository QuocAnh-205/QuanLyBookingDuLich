import 'package:mobile/features/explore/data/models/explore_models.dart';

class SearchResult {
  final List<Tour> tours;
  final List<Guide> guides;
  final List<Location> locations;

  SearchResult({
    required this.tours,
    required this.guides,
    required this.locations,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      tours: (json['tours'] as List? ?? []).map((e) => Tour.fromJson(e)).toList(),
      guides: (json['guides'] as List? ?? []).map((e) => Guide.fromJson(e)).toList(),
      locations: (json['locations'] as List? ?? []).map((e) => Location.fromJson(e)).toList(),
    );
  }

  bool get isEmpty => tours.isEmpty && guides.isEmpty && locations.isEmpty;
}

class SearchHistoryItem {
  final int id;
  final String keyword;
  final DateTime createdAt;

  SearchHistoryItem({
    required this.id,
    required this.keyword,
    required this.createdAt,
  });

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      id: json['history_id'],
      keyword: json['keyword'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
