import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      _error = 'Failed to request location permission: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> getCurrentPosition() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        _error = 'Location permission denied';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to get location: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Position>> getNearbyPositions(double radiusInMeters) async {
    if (_currentPosition == null) {
      await getCurrentPosition();
    }

    if (_currentPosition == null) return [];

    try {
      final positions = await Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).take(1).toList();

      return positions;
    } catch (e) {
      _error = 'Failed to get nearby positions: $e';
      notifyListeners();
      return [];
    }
  }
}