import 'package:flutter/material.dart';
import '../../data/models/trip_models.dart';
import '../../data/services/trip_service.dart';

class TripsProvider with ChangeNotifier {
  final TripService _tripService = TripService();
  
  List<Trip> _currentTrips = [];
  List<Trip> _nextTrips = [];
  List<Trip> _pastTrips = [];
  bool _isLoading = false;
  String? _error;
  Trip? _selectedTrip;

  List<Trip> get currentTrips => _currentTrips;
  List<Trip> get nextTrips => _nextTrips;
  List<Trip> get pastTrips => _pastTrips;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Trip? get selectedTrip => _selectedTrip;

  Future<void> fetchTrips(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Fetch all types concurrently
      final results = await Future.wait([
        _tripService.fetchMyBookings('current', token),
        _tripService.fetchMyBookings('next', token),
        _tripService.fetchMyBookings('past', token),
      ]);

      final current = results[0];
      final next = results[1];
      final past = results[2];
      
      final seenIds = <int>{};
      
      _currentTrips = current
          .map((json) => Trip.fromJson(json))
          .where((t) => seenIds.add(t.id))
          .toList();
          
      _nextTrips = next
          .map((json) => Trip.fromJson(json))
          .where((t) => seenIds.add(t.id))
          .toList();
          
      _pastTrips = past
          .map((json) => Trip.fromJson(json))
          .where((t) => seenIds.add(t.id))
          .toList();
          
    } catch (e) {
      _error = e.toString();
      debugPrint('Fetch Trips Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTripDetail(int id, String token) async {
    _isLoading = true;
    _error = null;
    _selectedTrip = null;
    notifyListeners();
    
    try {
      final data = await _tripService.fetchBookingDetail(id, token);
      _selectedTrip = Trip.fromJson(data);
    } catch (e) {
      _error = e.toString();
      debugPrint('Fetch Trip Detail Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(int id, String status, String token, {String? reason}) async {
    try {
      await _tripService.updateBookingStatus(id, status, token, reason: reason);
      // Refresh details if this is the selected trip
      if (_selectedTrip?.id == id) {
        await fetchTripDetail(id, token);
      }
      // Refresh lists
      await fetchTrips(token);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> selectBid(int bookingId, int bidId, String token) async {
    try {
      await _tripService.selectBid(bookingId, bidId, token);
      if (_selectedTrip?.id == bookingId) {
        await fetchTripDetail(bookingId, token);
      }
      await fetchTrips(token);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void addLocalTrip(Trip trip) {
    _nextTrips.insert(0, trip);
    notifyListeners();
  }
}
