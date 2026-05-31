import 'package:flutter/material.dart';
import '../../data/models/profile_model.dart';
import '../../data/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
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
    } catch (e) {
      _error = e.toString();
      debugPrint('Fetch Profile Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile via API
  Future<bool> updateProfile(Map<String, dynamic> data, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedData = await _profileService.updateProfile(data, token);
      // Re-fetch or merge to ensure we have all associations
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
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initial mock data (keep for offline testing if needed, but remove from main flow)
  void setMockProfile() {
    // Already implemented in previous phase
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
