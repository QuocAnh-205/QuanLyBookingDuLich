import 'package:flutter/material.dart';
import '../../data/services/wishlist_service.dart';
import '../../../../features/explore/data/models/explore_models.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _service = WishlistService();
  
  Set<int> _tourIds = {};
  Set<int> _expIds = {};
  List<Tour> _wishlistTours = [];
  List<Experience> _wishlistExperiences = [];
  bool _isLoading = false;

  Set<int> get tourIds => _tourIds;
  Set<int> get expIds => _expIds;
  List<Tour> get wishlistTours => _wishlistTours;
  List<Experience> get wishlistExperiences => _wishlistExperiences;
  bool get isLoading => _isLoading;

  bool isFavorite(int id, {bool isTour = true}) => 
      isTour ? _tourIds.contains(id) : _expIds.contains(id);

  Future<void> fetchWishlist(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final itemsMap = await _service.getWishlistItems(token);
      _wishlistTours = List<Tour>.from(itemsMap['tours'] ?? []);
      _wishlistExperiences = List<Experience>.from(itemsMap['experiences'] ?? []);
      
      _tourIds = _wishlistTours.map((t) => t.id).toSet();
      _expIds = _wishlistExperiences.map((e) => e.id).toSet();
    } catch (e) {
      debugPrint('Error fetching wishlist: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleWishlist(String token, {int? tourId, int? expId}) async {
    final bool isTour = tourId != null;
    final targetId = tourId ?? expId;
    if (targetId == null) return;

    final targetSet = isTour ? _tourIds : _expIds;

    // Optimistic UI update
    if (targetSet.contains(targetId)) {
      targetSet.remove(targetId);
    } else {
      targetSet.add(targetId);
    }
    notifyListeners();

    try {
      await _service.toggleWishlist(
        token: token,
        tourId: tourId,
        expId: expId,
      );
      // Refresh to get full objects if added, or remove from local list
      await fetchWishlist(token);
    } catch (e) {
      // Rollback on failure
      if (targetSet.contains(targetId)) {
        targetSet.remove(targetId);
      } else {
        targetSet.add(targetId);
      }
      notifyListeners();
      debugPrint('Error toggling wishlist: $e');
    }
  }
}
