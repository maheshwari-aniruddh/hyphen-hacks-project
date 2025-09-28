import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shelter.dart';
import 'location_service.dart';
import 'real_data_service.dart';

class ShelterService {
  static final ShelterService _instance = ShelterService._internal();
  factory ShelterService() => _instance;
  ShelterService._internal();

  final LocationService _locationService = LocationService();
  final RealDataService _realDataService = RealDataService();
  
  // Mock data for demonstration - in a real app, this would come from APIs
  final List<Shelter> _mockShelters = [
    Shelter(
      id: '1',
      name: 'Hope Shelter',
      address: '123 Main St, Downtown',
      latitude: 37.7749,
      longitude: -122.4194,
      phone: '(555) 123-4567',
      website: 'https://hopeshelter.org',
      description: 'Emergency shelter providing temporary housing and meals',
      services: ['Emergency shelter', 'Meals', 'Counseling', 'Job assistance'],
      hours: '24/7',
      capacity: 50,
      acceptsFamilies: true,
      acceptsPets: false,
      requirements: ['ID required', 'Background check'],
      rating: 4.2,
      reviewCount: 45,
    ),
    Shelter(
      id: '2',
      name: 'Grace House',
      address: '456 Oak Ave, Midtown',
      latitude: 37.7849,
      longitude: -122.4094,
      phone: '(555) 234-5678',
      website: 'https://gracehouse.org',
      description: 'Family shelter with childcare services',
      services: ['Family shelter', 'Childcare', 'Meals', 'Education programs'],
      hours: '6 PM - 7 AM',
      capacity: 30,
      acceptsFamilies: true,
      acceptsPets: true,
      requirements: ['Family with children', 'No ID required'],
      rating: 4.5,
      reviewCount: 32,
    ),
    Shelter(
      id: '3',
      name: 'New Beginnings Center',
      address: '789 Pine St, Uptown',
      latitude: 37.7649,
      longitude: -122.4294,
      phone: '(555) 345-6789',
      website: 'https://newbeginnings.org',
      description: 'Transitional housing with job training programs',
      services: ['Transitional housing', 'Job training', 'Mental health', 'Substance abuse counseling'],
      hours: '24/7',
      capacity: 25,
      acceptsFamilies: false,
      acceptsPets: false,
      requirements: ['Commitment to program', 'Clean drug test'],
      rating: 4.8,
      reviewCount: 28,
    ),
  ];

  /// Get all shelters (now uses real data)
  Future<List<Shelter>> getAllShelters() async {
    try {
      // Try to get real data first
      final realShelters = await _realDataService.searchRealShelters();
      if (realShelters.isNotEmpty) {
        return realShelters;
      }
    } catch (e) {
      print('Error fetching real shelters, falling back to mock data: $e');
    }
    
    // Fallback to mock data if real data fails
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_mockShelters);
  }

  /// Get nearby shelters within specified radius
  Future<List<Shelter>> getNearbyShelters({double radiusInMiles = 10.0}) async {
    List<Shelter> allShelters = await getAllShelters();
    
    if (_locationService.currentPosition == null) {
      await _locationService.getCurrentLocation();
    }

    if (_locationService.currentPosition == null) {
      return allShelters; // Return all if location not available
    }

    List<Shelter> nearbyShelters = _locationService.getNearbyLocations(
      allShelters,
      radiusInMiles,
      (shelter) => shelter.latitude,
      (shelter) => shelter.longitude,
    );

    // Add distance to each shelter
    return nearbyShelters.map((shelter) {
      double distance = _locationService.calculateDistance(
        _locationService.currentPosition!.latitude,
        _locationService.currentPosition!.longitude,
        shelter.latitude,
        shelter.longitude,
      );
      return Shelter(
        id: shelter.id,
        name: shelter.name,
        address: shelter.address,
        latitude: shelter.latitude,
        longitude: shelter.longitude,
        phone: shelter.phone,
        website: shelter.website,
        description: shelter.description,
        services: shelter.services,
        hours: shelter.hours,
        capacity: shelter.capacity,
        acceptsFamilies: shelter.acceptsFamilies,
        acceptsPets: shelter.acceptsPets,
        requirements: shelter.requirements,
        distance: distance,
        rating: shelter.rating,
        reviewCount: shelter.reviewCount,
      );
    }).toList();
  }

  /// Search shelters by name or services
  Future<List<Shelter>> searchShelters(String query) async {
    List<Shelter> allShelters = await getAllShelters();
    
    if (query.isEmpty) return allShelters;

    String lowercaseQuery = query.toLowerCase();
    
    return allShelters.where((shelter) {
      return shelter.name.toLowerCase().contains(lowercaseQuery) ||
             shelter.description?.toLowerCase().contains(lowercaseQuery) == true ||
             shelter.services.any((service) => service.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Filter shelters by criteria
  Future<List<Shelter>> filterShelters({
    bool? acceptsFamilies,
    bool? acceptsPets,
    List<String>? requiredServices,
    double? maxDistance,
  }) async {
    List<Shelter> shelters = await getNearbyShelters(radiusInMiles: maxDistance ?? 50.0);

    return shelters.where((shelter) {
      if (acceptsFamilies != null && shelter.acceptsFamilies != acceptsFamilies) {
        return false;
      }
      if (acceptsPets != null && shelter.acceptsPets != acceptsPets) {
        return false;
      }
      if (requiredServices != null && requiredServices.isNotEmpty) {
        bool hasAllServices = requiredServices.every((service) =>
            shelter.services.any((shelterService) =>
                shelterService.toLowerCase().contains(service.toLowerCase())));
        if (!hasAllServices) return false;
      }
      return true;
    }).toList();
  }

  /// Get shelter details by ID
  Future<Shelter?> getShelterById(String id) async {
    List<Shelter> shelters = await getAllShelters();
    try {
      return shelters.firstWhere((shelter) => shelter.id == id);
    } catch (e) {
      return null;
    }
  }
}

