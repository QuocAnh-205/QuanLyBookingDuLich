import 'package:flutter/material.dart';
import '../../data/models/explore_models.dart';
import '../../data/services/explore_service.dart';

class ExploreProvider extends ChangeNotifier {
  final ExploreService _exploreService = ExploreService();

  List<Location> _popularLocations = [];
  List<Tour> _featuredTours = [];
  List<Guide> _bestGuides = [];
  List<Experience> _topExperiences = [];
  List<TravelNews> _travelNews = [];

  bool _isLoading = false;
  String? _error;

  List<Location> get popularLocations => _popularLocations;
  List<Tour> get featuredTours => _featuredTours;
  List<Guide> get bestGuides => _bestGuides;
  List<Experience> get topExperiences => _topExperiences;
  List<TravelNews> get travelNews => _travelNews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ExploreProvider() {
    fetchExploreData();
  }

  Future<void> fetchExploreData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _exploreService.getExploreOverview();
      
      _popularLocations = (data['locations'] as List)
          .map((item) => Location.fromJson(item))
          .toList();
      
      _featuredTours = (data['tours'] as List)
          .map((item) => Tour.fromJson(item))
          .toList();
      
      _bestGuides = (data['guides'] as List)
          .map((item) => Guide.fromJson(item))
          .toList();
          
      _topExperiences = (data['experiences'] as List)
          .map((item) => Experience.fromJson(item))
          .toList();
          
      _travelNews = (data['news'] as List)
          .map((item) => TravelNews.fromJson(item))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(int? tourId, int? expId, String token) async {
    try {
      await _exploreService.toggleWishlist(tourId, expId, token);
      // Optional: Refresh local state or show success message
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
