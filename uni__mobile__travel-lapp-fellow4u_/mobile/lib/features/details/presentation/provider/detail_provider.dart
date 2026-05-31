import 'package:flutter/material.dart';
import '../../data/models/detail_models.dart';
import '../../data/services/detail_service.dart';
import '../../../explore/data/models/explore_models.dart';

class DetailProvider extends ChangeNotifier {
  final DetailService _detailService = DetailService();

  TourDetailFull? _selectedTour;
  Experience? _selectedExperience;
  GuideFullProfile? _selectedGuide;
  LocationFullDetail? _selectedLocation;

  bool _isLoading = false;
  String? _error;

  TourDetailFull? get selectedTour => _selectedTour;
  Experience? get selectedExperience => _selectedExperience;
  GuideFullProfile? get selectedGuide => _selectedGuide;
  LocationFullDetail? get selectedLocation => _selectedLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTourDetail(int id) async {
    _setLoading(true);
    try {
      _selectedTour = await _detailService.getTourDetail(id);
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _setError('Could not load tour details. Please check your connection.');
    }
  }

  Future<void> fetchExperienceDetail(int id) async {
    _setLoading(true);
    try {
      _selectedExperience = await _detailService.getExperienceDetail(id);
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _setError('Could not load experience details.');
    }
  }

  Future<void> fetchGuideDetail(int id) async {
    _setLoading(true);
    try {
      _selectedGuide = await _detailService.getGuideDetail(id);
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _setError('Could not load guide profile.');
    }
  }

  Future<void> fetchLocationDetail(int id) async {
    _setLoading(true);
    try {
      _selectedLocation = await _detailService.getLocationDetail(id);
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _setError('Could not load location details.');
    }
  }

  void clearSelection() {
    _selectedTour = null;
    _selectedExperience = null;
    _selectedGuide = null;
    _selectedLocation = null;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}
