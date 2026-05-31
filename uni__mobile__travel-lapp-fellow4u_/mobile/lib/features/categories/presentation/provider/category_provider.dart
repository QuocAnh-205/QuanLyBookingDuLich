import 'package:flutter/material.dart';
import '../../data/models/category_models.dart';
import '../../data/services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  BannerModel? _activeBanner;
  CollectionDetail? _currentCollection;
  bool _isLoading = false;
  String? _error;

  BannerModel? get activeBanner => _activeBanner;
  CollectionDetail? get currentCollection => _currentCollection;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchExtendedView(String pageType, String collectionSlug) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final banners = await _service.getBanners(pageType);
      if (banners.isNotEmpty) {
        _activeBanner = banners.first;
      }
      
      _currentCollection = await _service.getCollectionDetail(collectionSlug);
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }
}
