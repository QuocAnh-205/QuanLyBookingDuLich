import 'package:flutter/material.dart';
import '../../data/models/search_models.dart';
import '../../data/services/search_service.dart';

class SearchProvider extends ChangeNotifier {
  final SearchService _searchService = SearchService();
  
  SearchResult? _results;
  List<String> _popularKeywords = [];
  List<SearchHistoryItem> _userHistory = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  double? minPrice;
  double? maxPrice;
  int? locationId;
  String? selectedType;

  SearchResult? get results => _results;
  List<String> get popularKeywords => _popularKeywords;
  List<SearchHistoryItem> get userHistory => _userHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSuggestions(String? token) async {
    _popularKeywords = await _searchService.getPopularSearches();
    if (token != null) {
      _userHistory = await _searchService.getUserHistory(token);
    }
    notifyListeners();
  }

  Future<void> performSearch(String query, {String? token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await _searchService.search(
        query: query,
        type: selectedType,
        minPrice: minPrice,
        maxPrice: maxPrice,
        locationId: locationId,
        token: token,
      );
      _isLoading = false;
    } catch (e) {
      _error = 'Search failed. Please try again.';
      _isLoading = false;
    }
    notifyListeners();
  }

  void updateFilters({double? min, double? max, int? loc, String? type}) {
    minPrice = min;
    maxPrice = max;
    locationId = loc;
    selectedType = type;
    notifyListeners();
  }

  void clearResults() {
    _results = null;
    _error = null;
    notifyListeners();
  }
}
