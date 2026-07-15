import 'package:flutter/material.dart';
import '../../data/models/profile_model.dart';
import '../../data/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  
  UserProfile? _profile;
  List<UserPhoto> _allPhotos = [];
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  List<UserPhoto> get allPhotos => _allPhotos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch full profile from API
  Future<void> fetchProfile(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _profileService.fetchProfile(token);
      _profile = UserProfile.fromJson(data);
      // Fetch all photos as well
      await fetchPhotos(token);
    } catch (e) {
      _error = e.toString();
      debugPrint('Fetch Profile Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all photos
  Future<void> fetchPhotos(String token) async {
    try {
      final data = await _profileService.fetchPhotos(token);
      _allPhotos = data.map((p) => UserPhoto.fromJson(p)).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Fetch Photos Error: $e');
    }
  }

  // Update profile via API
  Future<bool> updateProfile(Map<String, dynamic> data, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedData = await _profileService.updateProfile(data, token);
      await fetchProfile(token);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update settings via API
  Future<bool> updateSettings(Map<String, dynamic> data, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _profileService.updateSettings(data, token);
      await fetchProfile(token);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete photo via API
  Future<bool> deletePhoto(int id, String token) async {
    try {
      await _profileService.deletePhoto(id, token);
      _profile?.photos.removeWhere((p) => p.id == id);
      _allPhotos.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete journey via API
  Future<bool> deleteJourney(int id, String token) async {
    try {
      await _profileService.deleteJourney(id, token);
      _profile?.journeys.removeWhere((j) => j.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addPhoto(String url, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _profileService.uploadPhoto({
        'image_url': url,
        'is_public': true,
      }, token);
      final newPhoto = UserPhoto.fromJson(data);
      _profile?.photos.insert(0, newPhoto);
      _allPhotos.insert(0, newPhoto);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create journey via API
  Future<bool> createJourney({
    required String title,
    required String locationName,
    required String description,
    required List<int> photoIds,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _profileService.createJourney({
        'title': title,
        'location_name': locationName,
        'description': description,
        'photo_ids': photoIds,
      }, token);
      await fetchProfile(token);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initial mock data
  void setMockProfile() {
    // Already implemented
  }

  // Change password via API
  Future<bool> changePassword(Map<String, dynamic> data, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _profileService.changePassword(data, token);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
