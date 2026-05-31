import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_models.dart';

class CategoryService {
  final String baseUrl = 'http://localhost:3000/api/categories';

  Future<List<BannerModel>> getBanners(String pageType) async {
    final response = await http.get(Uri.parse('$baseUrl/banners?page_type=$pageType'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return (decoded['data'] as List).map((e) => BannerModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<CollectionDetail> getCollectionDetail(String slug) async {
    final response = await http.get(Uri.parse('$baseUrl/collections/$slug'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return CollectionDetail.fromJson(decoded['data']);
    } else {
      throw Exception('Failed to load collection');
    }
  }
}
