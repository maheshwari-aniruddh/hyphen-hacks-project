import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_location.dart';
import 'location_service.dart';

class FoodService {
  static final FoodService _instance = FoodService._internal();
  factory FoodService() => _instance;
  FoodService._internal();

  final LocationService _locationService = LocationService();
  
  // Mock data for demonstration - in a real app, this would come from APIs
  final List<FoodLocation> _mockFoodLocations = [
    FoodLocation(
      id: '1',
      name: 'Community Kitchen',
      address: '100 Food St, Downtown',
      latitude: 37.7749,
      longitude: -122.4194,
      phone: '(555) 111-2222',
      website: 'https://communitykitchen.org',
      description: 'Free hot meals served daily',
      mealTypes: ['Breakfast', 'Lunch', 'Dinner'],
      hours: '6 AM - 8 PM',
      requirements: ['No ID required', 'First come first serve'],
      acceptsFamilies: true,
      rating: 4.3,
      reviewCount: 67,
      organization: 'Community Kitchen',
    ),
    FoodLocation(
      id: '2',
      name: 'Salvation Army Food Bank',
      address: '200 Hope Ave, Midtown',
      latitude: 37.7849,
      longitude: -122.4094,
      phone: '(555) 222-3333',
      website: 'https://salvationarmy.org',
      description: 'Food pantry and meal distribution',
      mealTypes: ['Lunch', 'Dinner', 'Snacks'],
      hours: '11 AM - 6 PM',
      requirements: ['No ID required'],
      acceptsFamilies: true,
      rating: 4.6,
      reviewCount: 89,
      organization: 'Salvation Army',
    ),
    FoodLocation(
      id: '3',
      name: 'St. Mary\'s Soup Kitchen',
      address: '300 Church St, Uptown',
      latitude: 37.7649,
      longitude: -122.4294,
      phone: '(555) 333-4444',
      website: 'https://stmarys.org',
      description: 'Weekly soup kitchen and food distribution',
      mealTypes: ['Dinner', 'Snacks'],
      hours: '5 PM - 7 PM (Wed & Fri)',
      requirements: ['No ID required', 'All welcome'],
      acceptsFamilies: true,
      rating: 4.7,
      reviewCount: 43,
      organization: 'St. Mary\'s Church',
    ),
    FoodLocation(
      id: '4',
      name: 'Mobile Food Truck',
      address: 'Various locations',
      latitude: 37.7549,
      longitude: -122.4394,
      phone: '(555) 444-5555',
      description: 'Mobile food truck serving different neighborhoods',
      mealTypes: ['Lunch', 'Snacks'],
      hours: '12 PM - 3 PM (Mon, Wed, Fri)',
      requirements: ['No ID required'],
      acceptsFamilies: true,
      rating: 4.4,
      reviewCount: 56,
      organization: 'Mobile Food Relief',
    ),
  ];

  /// Get all food locations
  Future<List<FoodLocation>> getAllFoodLocations() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_mockFoodLocations);
  }

  /// Get nearby food locations within specified radius
  Future<List<FoodLocation>> getNearbyFoodLocations({double radiusInMiles = 10.0}) async {
    List<FoodLocation> allLocations = await getAllFoodLocations();
    
    if (_locationService.currentPosition == null) {
      await _locationService.getCurrentLocation();
    }

    if (_locationService.currentPosition == null) {
      return allLocations; // Return all if location not available
    }

    List<FoodLocation> nearbyLocations = _locationService.getNearbyLocations(
      allLocations,
      radiusInMiles,
      (location) => location.latitude,
      (location) => location.longitude,
    );

    // Add distance to each location
    return nearbyLocations.map((location) {
      double distance = _locationService.calculateDistance(
        _locationService.currentPosition!.latitude,
        _locationService.currentPosition!.longitude,
        location.latitude,
        location.longitude,
      );
      return FoodLocation(
        id: location.id,
        name: location.name,
        address: location.address,
        latitude: location.latitude,
        longitude: location.longitude,
        phone: location.phone,
        website: location.website,
        description: location.description,
        mealTypes: location.mealTypes,
        hours: location.hours,
        requirements: location.requirements,
        acceptsFamilies: location.acceptsFamilies,
        distance: distance,
        rating: location.rating,
        reviewCount: location.reviewCount,
        organization: location.organization,
      );
    }).toList();
  }

  /// Search food locations by name or meal type
  Future<List<FoodLocation>> searchFoodLocations(String query) async {
    List<FoodLocation> allLocations = await getAllFoodLocations();
    
    if (query.isEmpty) return allLocations;

    String lowercaseQuery = query.toLowerCase();
    
    return allLocations.where((location) {
      return location.name.toLowerCase().contains(lowercaseQuery) ||
             location.description?.toLowerCase().contains(lowercaseQuery) == true ||
             location.mealTypes.any((mealType) => mealType.toLowerCase().contains(lowercaseQuery)) ||
             location.organization?.toLowerCase().contains(lowercaseQuery) == true;
    }).toList();
  }

  /// Filter food locations by criteria
  Future<List<FoodLocation>> filterFoodLocations({
    List<String>? mealTypes,
    bool? acceptsFamilies,
    double? maxDistance,
    String? organization,
  }) async {
    List<FoodLocation> locations = await getNearbyFoodLocations(radiusInMiles: maxDistance ?? 50.0);

    return locations.where((location) {
      if (mealTypes != null && mealTypes.isNotEmpty) {
        bool hasMealType = mealTypes.any((mealType) =>
            location.mealTypes.any((locationMealType) =>
                locationMealType.toLowerCase().contains(mealType.toLowerCase())));
        if (!hasMealType) return false;
      }
      if (acceptsFamilies != null && location.acceptsFamilies != acceptsFamilies) {
        return false;
      }
      if (organization != null && organization.isNotEmpty) {
        if (location.organization?.toLowerCase().contains(organization.toLowerCase()) != true) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Get food location details by ID
  Future<FoodLocation?> getFoodLocationById(String id) async {
    List<FoodLocation> locations = await getAllFoodLocations();
    try {
      return locations.firstWhere((location) => location.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get food locations open now
  Future<List<FoodLocation>> getFoodLocationsOpenNow() async {
    List<FoodLocation> allLocations = await getAllFoodLocations();
    DateTime now = DateTime.now();
    String currentDay = _getDayName(now.weekday);
    String currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return allLocations.where((location) {
      // Simple check - in a real app, you'd parse the hours more carefully
      if (location.hours == null) return false;
      
      // Check if it's a 24/7 location
      if (location.hours!.toLowerCase().contains('24/7')) return true;
      
      // Check if current day is mentioned in hours
      if (location.hours!.toLowerCase().contains(currentDay.toLowerCase())) return true;
      
      return false;
    }).toList();
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }
}
