import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/detail_models.dart';
import '../../../explore/data/models/explore_models.dart';

class DetailService {
  final String baseUrl = 'http://localhost:3000/api'; // Replace with your IP for real device

  Future<TourDetailFull> getTourDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/services/tours/$id'));
    if (response.statusCode == 200) {
      return TourDetailFull.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load tour details');
    }
  }

  Future<Experience> getExperienceDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/services/experiences/$id'));
    if (response.statusCode == 200) {
      return Experience.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load experience details');
    }
  }

  Future<GuideFullProfile> getGuideDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/guides/$id'));
    if (response.statusCode == 200) {
      return GuideFullProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load guide profile');
    }
  }

  Future<LocationFullDetail> getLocationDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/locations/$id'));
    if (response.statusCode == 200) {
      return LocationFullDetail.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load location details');
    }
  }
}
