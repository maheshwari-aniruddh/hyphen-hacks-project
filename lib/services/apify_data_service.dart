import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/shelter.dart';
import '../models/food_location.dart';
import '../models/job_listing.dart';
import '../models/user_profile.dart';

class ApifyDataService {
  static final ApifyDataService _instance = ApifyDataService._internal();
  factory ApifyDataService() => _instance;
  ApifyDataService._internal();

  // Replace with your actual Apify API endpoint and token
  final String _apifyRunId = 'rvFhxkPENWva7Xlyk';
  final String _apifyToken = 'apify_api_SS2ThgrLAZBOIqTXY0fObdq1UeU6ar3LXmLm';
  final String _apifyBaseUrl = 'https://api.apify.com/v2/actor-runs';

  Future<List<dynamic>> _fetchApifyDatasetItems(String datasetId) async {
    final url = 'https://api.apify.com/v2/datasets/$datasetId/items?token=$_apifyToken';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load data from Apify: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<Shelter>> getRealShelters(UserProfile? userProfile) async {
    try {
      final runDetailsUrl = '$_apifyBaseUrl/$_apifyRunId?token=$_apifyToken';
      final runDetailsResponse = await http.get(Uri.parse(runDetailsUrl));

      if (runDetailsResponse.statusCode == 200) {
        final runDetails = json.decode(runDetailsResponse.body)['data'];
        final datasetId = runDetails['defaultDatasetId'];
        final items = await _fetchApifyDatasetItems(datasetId);

        List<Shelter> shelters = items.map((item) {
          return Shelter(
            id: item['id']?.toString() ?? UniqueKey().toString(),
            name: item['title'] ?? 'Unknown Shelter',
            address: item['address'] ?? 'N/A',
            latitude: item['lat']?.toDouble(),
            longitude: item['lng']?.toDouble(),
            phone: item['phone'] ?? 'N/A',
            website: item['website'] ?? 'N/A',
            description: item['description'] ?? 'No description available.',
            capacity: item['capacity'] ?? 50,
            availability: item['availability'] ?? 'Call for availability',
            rules: item['rules'] ?? ['No drugs or alcohol'],
            services: item['services'] ?? ['Meals', 'Beds'],
            acceptsFamilies: item['acceptsFamilies'] ?? true,
            acceptsChildren: item['acceptsChildren'] ?? true,
            acceptsMen: item['acceptsMen'] ?? true,
            acceptsWomen: item['acceptsWomen'] ?? true,
            acceptsPets: item['acceptsPets'] ?? false,
            checkInTime: item['checkInTime'] ?? '5:00 PM',
            checkOutTime: item['checkOutTime'] ?? '8:00 AM',
            rating: item['totalScore']?.toDouble() ?? 0.0,
            reviewCount: item['reviewsCount'] ?? 0,
          );
        }).toList();

        // Apply personalization based on userProfile
        if (userProfile != null) {
          shelters = shelters.where((shelter) {
            bool matchesFamily = true;
            if (userProfile.familyStatus == 'With Children' && !shelter.acceptsChildren!) {
              matchesFamily = false;
            }
            if (userProfile.familyStatus == 'With Family' && !shelter.acceptsFamilies!) {
              matchesFamily = false;
            }
            // Add more personalization logic here based on userProfile.immediateNeeds, etc.
            return matchesFamily;
          }).toList();
        }
        return shelters;
      } else {
        throw Exception('Failed to fetch Apify run details: ${runDetailsResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching real shelters from Apify: $e');
      return []; // Fallback to empty list or mock data if needed
    }
  }

  Future<List<FoodLocation>> getRealFoodLocations(UserProfile? userProfile) async {
    try {
      // For now, return mock data for food locations
      // You can implement real food location fetching here
      return _getMockFoodLocations();
    } catch (e) {
      print('Error fetching real food locations: $e');
      return _getMockFoodLocations();
    }
  }

  Future<List<JobListing>> getRealJobs(UserProfile? userProfile) async {
    try {
      // For now, return mock data for jobs
      // You can implement real job scraping here
      return _getMockJobs();
    } catch (e) {
      print('Error fetching real jobs: $e');
      return _getMockJobs();
    }
  }

  // Personalized methods for compatibility
  Future<List<Shelter>> getPersonalizedShelters(UserProfile? userProfile) async {
    return await getRealShelters(userProfile);
  }

  Future<List<FoodLocation>> getPersonalizedFoodLocations(UserProfile? userProfile) async {
    return await getRealFoodLocations(userProfile);
  }

  Future<List<JobListing>> getPersonalizedJobs(UserProfile? userProfile) async {
    return await getRealJobs(userProfile);
  }

  List<FoodLocation> _getMockFoodLocations() {
    return [
      FoodLocation(
        id: '1',
        name: 'St. Anthony\'s Dining Room',
        address: '150 Golden Gate Ave, San Francisco, CA 94102',
        latitude: 37.7849,
        longitude: -122.4094,
        phone: '(415) 241-2600',
        description: 'Free meals served daily to anyone in need. No questions asked.',
        mealTypes: ['Breakfast', 'Lunch', 'Dinner'],
        hours: 'Breakfast: 6:30-7:30 AM, Lunch: 11:30 AM-1:00 PM, Dinner: 4:30-6:00 PM',
        days: 'Daily',
        requiresId: false,
        requiresReservation: false,
        capacity: 200,
        dietaryOptions: ['Vegetarian', 'Vegan', 'Gluten-free'],
        rating: 4.7,
        reviewCount: 45,
        organization: 'St. Anthony Foundation',
        contactPerson: 'Maria Rodriguez',
      ),
      FoodLocation(
        id: '2',
        name: 'Glide Memorial Church',
        address: '330 Ellis St, San Francisco, CA 94102',
        latitude: 37.7849,
        longitude: -122.4094,
        phone: '(415) 771-6300',
        description: 'Free meals and groceries for the community. All welcome.',
        mealTypes: ['Breakfast', 'Lunch', 'Dinner', 'Food Pantry'],
        hours: 'Meals: 6:00 AM-7:00 PM, Pantry: 9:00 AM-3:00 PM',
        days: 'Daily',
        requiresId: false,
        requiresReservation: false,
        capacity: 300,
        dietaryOptions: ['All'],
        rating: 4.8,
        reviewCount: 52,
        organization: 'Glide Memorial Church',
        contactPerson: 'Rev. Cecil Williams',
      ),
      FoodLocation(
        id: '3',
        name: 'San Francisco Food Bank',
        address: '900 Pennsylvania Ave, San Francisco, CA 94107',
        latitude: 37.7749,
        longitude: -122.4194,
        phone: '(415) 282-1900',
        description: 'Food distribution center providing groceries to families in need.',
        mealTypes: ['Food Pantry'],
        hours: '9:00 AM - 5:00 PM',
        days: 'Monday - Friday',
        requiresId: true,
        requiresReservation: true,
        capacity: 150,
        dietaryOptions: ['All'],
        rating: 4.5,
        reviewCount: 28,
        organization: 'San Francisco Food Bank',
        contactPerson: 'Jennifer Chen',
      ),
      FoodLocation(
        id: '4',
        name: 'Martin de Porres House of Hospitality',
        address: '225 Potrero Ave, San Francisco, CA 94103',
        latitude: 37.7649,
        longitude: -122.4094,
        phone: '(415) 552-0240',
        description: 'Free meals and hospitality services for the community.',
        mealTypes: ['Breakfast', 'Lunch', 'Dinner'],
        hours: 'Breakfast: 7:00-8:00 AM, Lunch: 12:00-1:00 PM, Dinner: 5:00-6:00 PM',
        days: 'Daily',
        requiresId: false,
        requiresReservation: false,
        capacity: 80,
        dietaryOptions: ['Vegetarian', 'Vegan'],
        rating: 4.6,
        reviewCount: 33,
        organization: 'Martin de Porres House',
        contactPerson: 'Father Tom',
      ),
      FoodLocation(
        id: '5',
        name: 'Hamilton Families',
        address: '260 Golden Gate Ave, San Francisco, CA 94102',
        latitude: 37.7849,
        longitude: -122.4094,
        phone: '(415) 409-2100',
        description: 'Meals and support services for families in need.',
        mealTypes: ['Breakfast', 'Lunch', 'Dinner'],
        hours: '7:00 AM - 7:00 PM',
        days: 'Daily',
        requiresId: true,
        requiresReservation: false,
        capacity: 60,
        dietaryOptions: ['All'],
        rating: 4.4,
        reviewCount: 19,
        organization: 'Hamilton Families',
        contactPerson: 'Lisa Thompson',
      ),
    ];
  }

  List<JobListing> _getMockJobs() {
    return [
      JobListing(
        id: '1',
        title: 'Kitchen Assistant',
        company: 'St. Anthony\'s Foundation',
        location: 'San Francisco, CA',
        latitude: 37.7849,
        longitude: -122.4094,
        description: 'Help prepare and serve meals to the community. No experience required, training provided.',
        salary: '\$18-22/hour',
        employmentType: 'Part-time',
        requirements: ['Reliable', 'Compassionate', 'Team player'],
        benefits: ['Free meals', 'Health insurance', 'Paid time off'],
        postedDate: '2024-01-15',
        jobUrl: 'https://stanthonysf.org/careers',
        rating: 4.5,
        reviewCount: 15,
        isEntryLevel: true,
        requiresExperience: false,
        skills: ['Food Service', 'Customer Service'],
      ),
      JobListing(
        id: '2',
        title: 'Maintenance Worker',
        company: 'San Francisco Housing Authority',
        location: 'San Francisco, CA',
        latitude: 37.7749,
        longitude: -122.4194,
        description: 'General maintenance and repair work for public housing facilities.',
        salary: '\$20-25/hour',
        employmentType: 'Full-time',
        requirements: ['Basic handyman skills', 'Valid driver\'s license'],
        benefits: ['Health insurance', 'Retirement plan', 'Paid vacation'],
        postedDate: '2024-01-14',
        jobUrl: 'https://sfha.org/careers',
        rating: 4.2,
        reviewCount: 8,
        isEntryLevel: true,
        requiresExperience: false,
        skills: ['Maintenance', 'Repair', 'Handyman'],
      ),
      JobListing(
        id: '3',
        title: 'Customer Service Representative',
        company: 'San Francisco Municipal Transportation Agency',
        location: 'San Francisco, CA',
        latitude: 37.7849,
        longitude: -122.4094,
        description: 'Help passengers with transit information and fare assistance.',
        salary: '\$19-23/hour',
        employmentType: 'Full-time',
        requirements: ['High school diploma', 'Customer service experience preferred'],
        benefits: ['Health insurance', 'Transit pass', 'Pension'],
        postedDate: '2024-01-13',
        jobUrl: 'https://sfmta.com/careers',
        rating: 4.0,
        reviewCount: 12,
        isEntryLevel: true,
        requiresExperience: false,
        skills: ['Customer Service', 'Communication'],
      ),
      JobListing(
        id: '4',
        title: 'Janitorial Staff',
        company: 'San Francisco International Airport',
        location: 'San Francisco, CA',
        latitude: 37.6213,
        longitude: -122.3790,
        description: 'Cleaning and maintenance of airport facilities. Flexible shifts available.',
        salary: '\$17-21/hour',
        employmentType: 'Part-time',
        requirements: ['Reliable', 'Able to lift 25 lbs'],
        benefits: ['Health insurance', 'Airport parking', 'Shift differential'],
        postedDate: '2024-01-12',
        jobUrl: 'https://flysfo.com/careers',
        rating: 3.8,
        reviewCount: 6,
        isEntryLevel: true,
        requiresExperience: false,
        skills: ['Cleaning', 'Maintenance'],
      ),
      JobListing(
        id: '5',
        title: 'Retail Associate',
        company: 'Goodwill Industries of San Francisco',
        location: 'San Francisco, CA',
        latitude: 37.7749,
        longitude: -122.4194,
        description: 'Customer service and sales in thrift store environment. Great for building retail experience.',
        salary: '\$16-19/hour',
        employmentType: 'Part-time',
        requirements: ['Friendly personality', 'Cash handling experience preferred'],
        benefits: ['Employee discount', 'Training programs', 'Flexible schedule'],
        postedDate: '2024-01-11',
        jobUrl: 'https://goodwillsf.org/careers',
        rating: 4.1,
        reviewCount: 9,
        isEntryLevel: true,
        requiresExperience: false,
        skills: ['Retail', 'Customer Service', 'Cash Handling'],
      ),
      JobListing(
        id: '6',
        title: 'Security Guard',
        company: 'Allied Universal Security',
        location: 'San Francisco, CA',
        latitude: 37.7849,
        longitude: -122.4094,
        description: 'Provide security services for various San Francisco locations. Training provided.',
        salary: '\$18-22/hour',
        employmentType: 'Full-time',
        requirements: ['Clean background check', 'Valid CA guard card'],
        benefits: ['Health insurance', 'Uniform provided', 'Overtime available'],
        postedDate: '2024-01-10',
        jobUrl: 'https://allieduniversal.com/careers',
        rating: 3.9,
        reviewCount: 7,
        isEntryLevel: true,
        requiresExperience: false,
        skills: ['Security', 'Observation', 'Communication'],
      ),
    ];
  }
}