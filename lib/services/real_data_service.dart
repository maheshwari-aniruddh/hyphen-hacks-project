import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shelter.dart';
import '../models/food_location.dart';
import '../models/job_listing.dart';
import 'location_service.dart';

class RealDataService {
  static final RealDataService _instance = RealDataService._internal();
  factory RealDataService() => _instance;
  RealDataService._internal();

  final LocationService _locationService = LocationService();
  
  // You'll need to get these API keys from Google Cloud Console
  static const String _googlePlacesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY';
  static const String _googleJobsApiKey = 'YOUR_GOOGLE_JOBS_API_KEY';
  
  // Base URLs for APIs
  static const String _googlePlacesBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _indeedApiBaseUrl = 'https://api.indeed.com/v2/jobs';
  static const String _usajobsApiBaseUrl = 'https://data.usajobs.gov/api/search';

  /// Search for shelters using Google Places API
  Future<List<Shelter>> searchRealShelters({double radiusInMeters = 10000}) async {
    if (_locationService.currentPosition == null) {
      await _locationService.getCurrentLocation();
    }

    if (_locationService.currentPosition == null) {
      return await _getFallbackShelters();
    }

    try {
      final lat = _locationService.currentPosition!.latitude;
      final lng = _locationService.currentPosition!.longitude;
      
      // Search for shelters
      final shelterResponse = await _searchGooglePlaces(
        query: 'shelter',
        location: '$lat,$lng',
        radius: radiusInMeters,
        type: 'lodging',
      );

      // Search for emergency shelters
      final emergencyResponse = await _searchGooglePlaces(
        query: 'emergency shelter',
        location: '$lat,$lng',
        radius: radiusInMeters,
        type: 'lodging',
      );

      List<Shelter> shelters = [];
      
      // Process shelter results
      if (shelterResponse['results'] != null) {
        shelters.addAll(_parseShelterResults(shelterResponse['results']));
      }
      
      // Process emergency shelter results
      if (emergencyResponse['results'] != null) {
        shelters.addAll(_parseShelterResults(emergencyResponse['results']));
      }

      // Remove duplicates based on place_id
      shelters = shelters.fold<List<Shelter>>([], (list, shelter) {
        if (!list.any((s) => s.id == shelter.id)) {
          list.add(shelter);
        }
        return list;
      });

      return shelters;
    } catch (e) {
      print('Error fetching real shelters: $e');
      return await _getFallbackShelters();
    }
  }

  /// Search for food banks and soup kitchens using Google Places API
  Future<List<FoodLocation>> searchRealFoodLocations({double radiusInMeters = 10000}) async {
    if (_locationService.currentPosition == null) {
      await _locationService.getCurrentLocation();
    }

    if (_locationService.currentPosition == null) {
      return await _getFallbackFoodLocations();
    }

    try {
      final lat = _locationService.currentPosition!.latitude;
      final lng = _locationService.currentPosition!.longitude;
      
      // Search for food banks
      final foodBankResponse = await _searchGooglePlaces(
        query: 'food bank',
        location: '$lat,$lng',
        radius: radiusInMeters,
        type: 'food',
      );

      // Search for soup kitchens
      final soupKitchenResponse = await _searchGooglePlaces(
        query: 'soup kitchen',
        location: '$lat,$lng',
        radius: radiusInMeters,
        type: 'food',
      );

      // Search for free meals
      final freeMealsResponse = await _searchGooglePlaces(
        query: 'free meals',
        location: '$lat,$lng',
        radius: radiusInMeters,
        type: 'food',
      );

      List<FoodLocation> foodLocations = [];
      
      // Process all results
      if (foodBankResponse['results'] != null) {
        foodLocations.addAll(_parseFoodLocationResults(foodBankResponse['results'], 'Food Bank'));
      }
      
      if (soupKitchenResponse['results'] != null) {
        foodLocations.addAll(_parseFoodLocationResults(soupKitchenResponse['results'], 'Soup Kitchen'));
      }
      
      if (freeMealsResponse['results'] != null) {
        foodLocations.addAll(_parseFoodLocationResults(freeMealsResponse['results'], 'Free Meals'));
      }

      // Remove duplicates
      foodLocations = foodLocations.fold<List<FoodLocation>>([], (list, location) {
        if (!list.any((l) => l.id == location.id)) {
          list.add(location);
        }
        return list;
      });

      return foodLocations;
    } catch (e) {
      print('Error fetching real food locations: $e');
      return await _getFallbackFoodLocations();
    }
  }

  /// Search for real job listings using Indeed API and other sources
  Future<List<JobListing>> searchRealJobs({String? location, String? query}) async {
    try {
      List<JobListing> jobs = [];
      
      // Search Indeed API for entry-level jobs
      final indeedJobs = await _searchIndeedJobs(
        query: query ?? 'entry level',
        location: location ?? _getCurrentCity(),
      );
      jobs.addAll(indeedJobs);

      // Search USAJobs for government positions
      final usajobs = await _searchUSAJobs(
        query: query ?? 'entry level',
        location: location ?? _getCurrentCity(),
      );
      jobs.addAll(usajobs);

      // Search for local job boards
      final localJobs = await _searchLocalJobBoards(
        query: query ?? 'entry level',
        location: location ?? _getCurrentCity(),
      );
      jobs.addAll(localJobs);

      return jobs;
    } catch (e) {
      print('Error fetching real jobs: $e');
      return await _getFallbackJobs();
    }
  }

  /// Search Google Places API
  Future<Map<String, dynamic>> _searchGooglePlaces({
    required String query,
    required String location,
    required double radius,
    String? type,
  }) async {
    final url = Uri.parse('$_googlePlacesBaseUrl/textsearch/json');
    final params = {
      'query': query,
      'location': location,
      'radius': radius.toString(),
      'key': _googlePlacesApiKey,
    };
    
    if (type != null) {
      params['type'] = type;
    }

    final response = await http.get(url.replace(queryParameters: params));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load places: ${response.statusCode}');
    }
  }

  /// Parse Google Places results into Shelter objects
  List<Shelter> _parseShelterResults(List<dynamic> results) {
    return results.map((place) {
      final geometry = place['geometry'];
      final location = geometry['location'];
      
      return Shelter(
        id: place['place_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: place['name'] ?? 'Unknown Shelter',
        address: place['formatted_address'] ?? 'Address not available',
        latitude: location['lat']?.toDouble() ?? 0.0,
        longitude: location['lng']?.toDouble() ?? 0.0,
        phone: place['formatted_phone_number'] ?? '',
        website: place['website'] ?? '',
        description: place['editorial_summary']?['overview'] ?? 'Emergency shelter providing temporary housing',
        services: _extractServices(place),
        hours: _formatHours(place['opening_hours']),
        rating: place['rating']?.toDouble() ?? 0.0,
        reviewCount: place['user_ratings_total'] ?? 0,
        acceptsFamilies: _checkAcceptsFamilies(place),
        acceptsPets: _checkAcceptsPets(place),
        requirements: _extractRequirements(place),
        distance: _locationService.currentPosition != null 
            ? _locationService.calculateDistance(
                _locationService.currentPosition!.latitude,
                _locationService.currentPosition!.longitude,
                location['lat']?.toDouble() ?? 0.0,
                location['lng']?.toDouble() ?? 0.0,
              )
            : null,
      );
    }).toList();
  }

  /// Parse Google Places results into FoodLocation objects
  List<FoodLocation> _parseFoodLocationResults(List<dynamic> results, String organization) {
    return results.map((place) {
      final geometry = place['geometry'];
      final location = geometry['location'];
      
      return FoodLocation(
        id: place['place_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: place['name'] ?? 'Unknown Food Location',
        address: place['formatted_address'] ?? 'Address not available',
        latitude: location['lat']?.toDouble() ?? 0.0,
        longitude: location['lng']?.toDouble() ?? 0.0,
        phone: place['formatted_phone_number'] ?? '',
        website: place['website'] ?? '',
        description: place['editorial_summary']?['overview'] ?? 'Free food distribution',
        mealTypes: _extractMealTypes(place),
        hours: _formatHours(place['opening_hours']),
        requirements: _extractFoodRequirements(place),
        acceptsFamilies: true, // Most food locations accept families
        rating: place['rating']?.toDouble() ?? 0.0,
        reviewCount: place['user_ratings_total'] ?? 0,
        organization: organization,
        distance: _locationService.currentPosition != null 
            ? _locationService.calculateDistance(
                _locationService.currentPosition!.latitude,
                _locationService.currentPosition!.longitude,
                location['lat']?.toDouble() ?? 0.0,
                location['lng']?.toDouble() ?? 0.0,
              )
            : null,
      );
    }).toList();
  }

  /// Search Indeed API for jobs
  Future<List<JobListing>> _searchIndeedJobs({required String query, required String location}) async {
    try {
      // Note: Indeed API requires authentication and has rate limits
      // This is a simplified example - you'd need to implement proper authentication
      final url = Uri.parse('$_indeedApiBaseUrl/search');
      final params = {
        'publisher': 'YOUR_INDEED_PUBLISHER_ID', // You need to register for this
        'q': query,
        'l': location,
        'sort': 'date',
        'radius': '25',
        'st': 'jobsite',
        'jt': 'fulltime,parttime',
        'start': '0',
        'limit': '25',
        'format': 'json',
        'v': '2',
      };

      final response = await http.get(url.replace(queryParameters: params));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseIndeedJobs(data['results'] ?? []);
      }
    } catch (e) {
      print('Error fetching Indeed jobs: $e');
    }
    return [];
  }

  /// Search USAJobs API for government positions
  Future<List<JobListing>> _searchUSAJobs({required String query, required String location}) async {
    try {
      final url = Uri.parse('$_usajobsApiBaseUrl');
      final params = {
        'Keyword': query,
        'LocationName': location,
        'ResultsPerPage': '25',
      };

      final response = await http.get(url.replace(queryParameters: params));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseUSAJobs(data['SearchResult']?['SearchResultItems'] ?? []);
      }
    } catch (e) {
      print('Error fetching USAJobs: $e');
    }
    return [];
  }

  /// Search local job boards (simplified implementation)
  Future<List<JobListing>> _searchLocalJobBoards({required String query, required String location}) async {
    // This would integrate with local job boards, Craigslist, etc.
    // For now, return empty list
    return [];
  }

  /// Parse Indeed job results
  List<JobListing> _parseIndeedJobs(List<dynamic> results) {
    return results.map((job) {
      return JobListing(
        id: job['jobkey'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: job['jobtitle'] ?? 'Unknown Position',
        company: job['company'] ?? 'Unknown Company',
        location: job['formattedLocation'] ?? 'Location not specified',
        description: job['snippet'] ?? '',
        salary: job['salary'] ?? '',
        employmentType: _parseEmploymentType(job['jobtype']),
        postedDate: _formatDate(job['date']),
        applicationUrl: job['url'] ?? '',
        isEntryLevel: _isEntryLevel(job['jobtitle'] ?? ''),
        requiresExperience: _requiresExperience(job['snippet'] ?? ''),
        skills: _extractJobSkills(job['snippet'] ?? ''),
        distance: _calculateJobDistance(job['formattedLocation'] ?? ''),
      );
    }).toList();
  }

  /// Parse USAJobs results
  List<JobListing> _parseUSAJobs(List<dynamic> results) {
    return results.map((job) {
      final jobData = job['MatchedObjectDescriptor'];
      return JobListing(
        id: jobData['PositionID'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: jobData['PositionTitle'] ?? 'Unknown Position',
        company: 'U.S. Government',
        location: jobData['PositionLocationDisplay'] ?? 'Location not specified',
        description: jobData['QualificationSummary'] ?? '',
        salary: jobData['PositionRemuneration']?[0]?['MinimumRange'] ?? '',
        employmentType: 'Full-time',
        postedDate: _formatDate(jobData['PublicationStartDate']),
        applicationUrl: jobData['ApplyURI']?[0] ?? '',
        isEntryLevel: _isEntryLevel(jobData['PositionTitle'] ?? ''),
        requiresExperience: _requiresExperience(jobData['QualificationSummary'] ?? ''),
        skills: _extractJobSkills(jobData['QualificationSummary'] ?? ''),
      );
    }).toList();
  }

  // Helper methods for parsing and formatting data
  List<String> _extractServices(Map<String, dynamic> place) {
    List<String> services = ['Emergency shelter'];
    
    // Extract services from place details
    if (place['types'] != null) {
      for (String type in place['types']) {
        switch (type) {
          case 'lodging':
            services.add('Temporary housing');
            break;
          case 'food':
            services.add('Meals');
            break;
          case 'health':
            services.add('Medical services');
            break;
        }
      }
    }
    
    return services;
  }

  List<String> _extractMealTypes(Map<String, dynamic> place) {
    List<String> mealTypes = ['Meals'];
    
    // Try to extract meal types from place details
    if (place['types'] != null) {
      for (String type in place['types']) {
        if (type.contains('restaurant')) {
          mealTypes.addAll(['Breakfast', 'Lunch', 'Dinner']);
        }
      }
    }
    
    return mealTypes;
  }

  String? _formatHours(Map<String, dynamic>? hours) {
    if (hours == null) return null;
    
    final weekdayText = hours['weekday_text'];
    if (weekdayText != null && weekdayText is List) {
      return weekdayText.join(', ');
    }
    
    return null;
  }

  bool _checkAcceptsFamilies(Map<String, dynamic> place) {
    // Most shelters accept families unless specifically noted otherwise
    return true;
  }

  bool _checkAcceptsPets(Map<String, dynamic> place) {
    // Check if place mentions pet-friendly
    final name = place['name']?.toLowerCase() ?? '';
    return name.contains('pet') || name.contains('animal');
  }

  List<String>? _extractRequirements(Map<String, dynamic> place) {
    List<String> requirements = [];
    
    // Extract requirements from place details
    final name = place['name']?.toLowerCase() ?? '';
    if (name.contains('id required')) {
      requirements.add('ID required');
    }
    
    return requirements.isNotEmpty ? requirements : null;
  }

  List<String>? _extractFoodRequirements(Map<String, dynamic> place) {
    return ['No ID required', 'All welcome'];
  }

  String _parseEmploymentType(String? jobType) {
    if (jobType == null) return 'Full-time';
    
    final type = jobType.toLowerCase();
    if (type.contains('part')) return 'Part-time';
    if (type.contains('contract')) return 'Contract';
    if (type.contains('temporary')) return 'Temporary';
    
    return 'Full-time';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Recently';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      
      if (difference == 0) return 'Today';
      if (difference == 1) return 'Yesterday';
      if (difference < 7) return '$difference days ago';
      if (difference < 30) return '${(difference / 7).floor()} weeks ago';
      
      return '${(difference / 30).floor()} months ago';
    } catch (e) {
      return 'Recently';
    }
  }

  bool _isEntryLevel(String title) {
    final lowerTitle = title.toLowerCase();
    return lowerTitle.contains('entry') || 
           lowerTitle.contains('junior') || 
           lowerTitle.contains('assistant') ||
           lowerTitle.contains('trainee');
  }

  bool _requiresExperience(String description) {
    final lowerDesc = description.toLowerCase();
    return lowerDesc.contains('experience required') || 
           lowerDesc.contains('years of experience') ||
           lowerDesc.contains('minimum');
  }

  List<String> _extractJobSkills(String description) {
    List<String> skills = [];
    final lowerDesc = description.toLowerCase();
    
    if (lowerDesc.contains('customer service')) skills.add('Customer service');
    if (lowerDesc.contains('communication')) skills.add('Communication');
    if (lowerDesc.contains('computer')) skills.add('Computer skills');
    if (lowerDesc.contains('teamwork')) skills.add('Teamwork');
    if (lowerDesc.contains('problem solving')) skills.add('Problem solving');
    
    return skills;
  }

  double? _calculateJobDistance(String location) {
    // This would calculate distance to job location
    // For now, return null
    return null;
  }

  String _getCurrentCity() {
    // This would get the current city from location service
    return 'San Francisco, CA'; // Default for demo
  }

  // Fallback methods with mock data
  Future<List<Shelter>> _getFallbackShelters() async {
    // Return mock data if API fails
    return [];
  }

  Future<List<FoodLocation>> _getFallbackFoodLocations() async {
    // Return mock data if API fails
    return [];
  }

  Future<List<JobListing>> _getFallbackJobs() async {
    // Return mock data if API fails
    return [];
  }
}

