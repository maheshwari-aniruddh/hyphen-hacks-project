import 'dart:math';
import '../models/shelter.dart';
import '../models/food_location.dart';
import '../models/job_listing.dart';
import '../models/user_profile.dart';
import '../services/location_service.dart';

class DemoDataService {
  static final DemoDataService _instance = DemoDataService._internal();
  factory DemoDataService() => _instance;
  DemoDataService._internal();

  final LocationService _locationService = LocationService();
  final Random _random = Random();

  // Realistic shelter data
  final List<Map<String, dynamic>> _shelterData = [
    {
      'name': 'Hope House Emergency Shelter',
      'address': '123 Main Street, Downtown',
      'phone': '(555) 123-4567',
      'services': ['Emergency shelter', 'Meals', 'Counseling', 'Job assistance'],
      'hours': '24/7',
      'capacity': 45,
      'acceptsFamilies': true,
      'acceptsPets': false,
      'requirements': ['ID required', 'Background check'],
      'rating': 4.2,
      'reviewCount': 67,
    },
    {
      'name': 'Grace Center Family Shelter',
      'address': '456 Oak Avenue, Midtown',
      'phone': '(555) 234-5678',
      'services': ['Family shelter', 'Childcare', 'Meals', 'Education programs'],
      'hours': '6 PM - 7 AM',
      'capacity': 30,
      'acceptsFamilies': true,
      'acceptsPets': true,
      'requirements': ['Family with children', 'No ID required'],
      'rating': 4.5,
      'reviewCount': 89,
    },
    {
      'name': 'New Beginnings Transitional Housing',
      'address': '789 Pine Street, Uptown',
      'phone': '(555) 345-6789',
      'services': ['Transitional housing', 'Job training', 'Mental health', 'Substance abuse counseling'],
      'hours': '24/7',
      'capacity': 25,
      'acceptsFamilies': false,
      'acceptsPets': false,
      'requirements': ['Commitment to program', 'Clean drug test'],
      'rating': 4.8,
      'reviewCount': 43,
    },
    {
      'name': 'Safe Haven Women\'s Shelter',
      'address': '321 Elm Street, Eastside',
      'phone': '(555) 456-7890',
      'services': ['Women\'s shelter', 'Counseling', 'Legal aid', 'Job training'],
      'hours': '24/7',
      'capacity': 20,
      'acceptsFamilies': true,
      'acceptsPets': true,
      'requirements': ['Women only', 'No ID required'],
      'rating': 4.6,
      'reviewCount': 52,
    },
    {
      'name': 'Community Outreach Center',
      'address': '654 Maple Drive, Westside',
      'phone': '(555) 567-8901',
      'services': ['Emergency shelter', 'Meals', 'Medical care', 'Housing assistance'],
      'hours': '24/7',
      'capacity': 60,
      'acceptsFamilies': true,
      'acceptsPets': false,
      'requirements': ['ID preferred', 'First come first serve'],
      'rating': 4.1,
      'reviewCount': 78,
    },
  ];

  // Realistic food location data
  final List<Map<String, dynamic>> _foodData = [
    {
      'name': 'Community Kitchen',
      'address': '100 Food Street, Downtown',
      'phone': '(555) 111-2222',
      'organization': 'Community Kitchen',
      'mealTypes': ['Breakfast', 'Lunch', 'Dinner'],
      'hours': '6 AM - 8 PM',
      'requirements': ['No ID required', 'First come first serve'],
      'rating': 4.3,
      'reviewCount': 67,
    },
    {
      'name': 'Salvation Army Food Bank',
      'address': '200 Hope Avenue, Midtown',
      'phone': '(555) 222-3333',
      'organization': 'Salvation Army',
      'mealTypes': ['Lunch', 'Dinner', 'Snacks'],
      'hours': '11 AM - 6 PM',
      'requirements': ['No ID required'],
      'rating': 4.6,
      'reviewCount': 89,
    },
    {
      'name': 'St. Mary\'s Soup Kitchen',
      'address': '300 Church Street, Uptown',
      'phone': '(555) 333-4444',
      'organization': 'St. Mary\'s Church',
      'mealTypes': ['Dinner', 'Snacks'],
      'hours': '5 PM - 7 PM (Wed & Fri)',
      'requirements': ['No ID required', 'All welcome'],
      'rating': 4.7,
      'reviewCount': 43,
    },
    {
      'name': 'Mobile Food Truck',
      'address': 'Various locations',
      'phone': '(555) 444-5555',
      'organization': 'Mobile Food Relief',
      'mealTypes': ['Lunch', 'Snacks'],
      'hours': '12 PM - 3 PM (Mon, Wed, Fri)',
      'requirements': ['No ID required'],
      'rating': 4.4,
      'reviewCount': 56,
    },
    {
      'name': 'Food Pantry Plus',
      'address': '500 Service Road, Eastside',
      'phone': '(555) 555-6666',
      'organization': 'Local Food Bank',
      'mealTypes': ['Breakfast', 'Lunch'],
      'hours': '8 AM - 2 PM (Tue, Thu, Sat)',
      'requirements': ['No ID required', 'All welcome'],
      'rating': 4.5,
      'reviewCount': 34,
    },
  ];

  // Realistic job data
  final List<Map<String, dynamic>> _jobData = [
    {
      'title': 'Warehouse Associate',
      'company': 'ABC Logistics',
      'location': 'Downtown',
      'salary': '\$15-18/hour',
      'employmentType': 'Full-time',
      'description': 'Entry-level warehouse position with on-the-job training. No experience required.',
      'requirements': ['No experience required', 'Must be able to lift 50 lbs', 'Reliable transportation'],
      'benefits': ['Health insurance', 'Paid time off', '401k'],
      'skills': ['Physical labor', 'Teamwork', 'Attention to detail'],
      'isEntryLevel': true,
      'requiresExperience': false,
      'rating': 3.8,
      'reviewCount': 23,
    },
    {
      'title': 'Food Service Worker',
      'company': 'City Diner',
      'location': 'Midtown',
      'salary': '\$12-15/hour + tips',
      'employmentType': 'Part-time',
      'description': 'Kitchen helper and server position. Great for people starting their career.',
      'requirements': ['Food handler permit preferred', 'Customer service skills'],
      'benefits': ['Flexible schedule', 'Free meals'],
      'skills': ['Customer service', 'Food preparation', 'Teamwork'],
      'isEntryLevel': true,
      'requiresExperience': false,
      'rating': 4.1,
      'reviewCount': 15,
    },
    {
      'title': 'Janitorial Staff',
      'company': 'CleanCorp',
      'location': 'Various locations',
      'salary': '\$14-16/hour',
      'employmentType': 'Full-time',
      'description': 'Cleaning positions at various office buildings. Immediate start available.',
      'requirements': ['Reliable transportation', 'Background check'],
      'benefits': ['Health insurance', 'Uniforms provided'],
      'skills': ['Cleaning', 'Attention to detail', 'Reliability'],
      'isEntryLevel': true,
      'requiresExperience': false,
      'rating': 3.9,
      'reviewCount': 31,
    },
    {
      'title': 'Retail Associate',
      'company': 'QuickMart',
      'location': 'Uptown',
      'salary': '\$13-16/hour',
      'employmentType': 'Part-time',
      'description': 'Cashier and stock clerk position. Perfect for entry-level workers.',
      'requirements': ['Basic math skills', 'Customer service'],
      'benefits': ['Employee discount', 'Flexible hours'],
      'skills': ['Cash handling', 'Customer service', 'Basic math'],
      'isEntryLevel': true,
      'requiresExperience': false,
      'rating': 4.0,
      'reviewCount': 42,
    },
    {
      'title': 'Construction Helper',
      'company': 'BuildRight Construction',
      'location': 'Various job sites',
      'salary': '\$16-20/hour',
      'employmentType': 'Full-time',
      'description': 'Entry-level construction work with training provided.',
      'requirements': ['Valid driver\'s license', 'Physical fitness'],
      'benefits': ['Health insurance', 'Tool allowance', 'Overtime pay'],
      'skills': ['Physical labor', 'Construction basics', 'Safety awareness'],
      'isEntryLevel': true,
      'requiresExperience': false,
      'rating': 4.2,
      'reviewCount': 18,
    },
    {
      'title': 'Security Guard',
      'company': 'SecureGuard Inc',
      'location': 'Various locations',
      'salary': '\$14-17/hour',
      'employmentType': 'Full-time',
      'description': 'Entry-level security position with training provided.',
      'requirements': ['Clean background', 'Reliable transportation'],
      'benefits': ['Health insurance', 'Uniforms', 'Paid training'],
      'skills': ['Observation', 'Communication', 'Reliability'],
      'isEntryLevel': true,
      'requiresExperience': false,
      'rating': 3.7,
      'reviewCount': 29,
    },
    {
      'title': 'Delivery Driver',
      'company': 'FastDelivery Co',
      'location': 'City-wide',
      'salary': '\$15-19/hour + tips',
      'employmentType': 'Part-time',
      'description': 'Flexible delivery driver position. Use your own vehicle.',
      'requirements': ['Valid driver\'s license', 'Own vehicle', 'Clean driving record'],
      'benefits': ['Flexible schedule', 'Tips', 'Mileage reimbursement'],
      'skills': ['Driving', 'Customer service', 'Time management'],
      'isEntryLevel': true,
      'requiresExperience': false,
      'rating': 4.3,
      'reviewCount': 37,
    },
    {
      'title': 'Landscaping Helper',
      'company': 'GreenThumb Landscaping',
      'location': 'Various locations',
      'salary': '\$13-16/hour',
      'employmentType': 'Full-time',
      'description': 'Outdoor landscaping work. Great for people who like physical work.',
      'requirements': ['Physical fitness', 'Reliable transportation'],
      'benefits': ['Health insurance', 'Tools provided', 'Outdoor work'],
      'skills': ['Physical labor', 'Landscaping basics', 'Teamwork'],
      'isEntryLevel': true,
      'requiresExperience': false,
      'rating': 4.0,
      'reviewCount': 25,
    },
  ];

  /// Get personalized shelters based on user profile
  Future<List<Shelter>> getPersonalizedShelters(UserProfile? userProfile) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    List<Shelter> shelters = [];
    
    for (var data in _shelterData) {
      final lat = 37.7749 + (_random.nextDouble() - 0.5) * 0.1;
      final lng = -122.4194 + (_random.nextDouble() - 0.5) * 0.1;
      
      shelters.add(Shelter(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_${shelters.length}',
        name: data['name'],
        address: data['address'],
        latitude: lat,
        longitude: lng,
        phone: data['phone'],
        description: 'Emergency shelter providing temporary housing and support services',
        services: List<String>.from(data['services']),
        hours: data['hours'],
        capacity: data['capacity'],
        acceptsFamilies: data['acceptsFamilies'],
        acceptsPets: data['acceptsPets'],
        requirements: List<String>.from(data['requirements']),
        distance: _calculateDistance(lat, lng),
        rating: data['rating'],
        reviewCount: data['reviewCount'],
      ));
    }
    
    // Personalize based on user profile
    if (userProfile != null) {
      shelters = _personalizeShelters(shelters, userProfile);
    }
    
    return shelters;
  }

  /// Get personalized food locations based on user profile
  Future<List<FoodLocation>> getPersonalizedFoodLocations(UserProfile? userProfile) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    List<FoodLocation> foodLocations = [];
    
    for (var data in _foodData) {
      final lat = 37.7749 + (_random.nextDouble() - 0.5) * 0.1;
      final lng = -122.4194 + (_random.nextDouble() - 0.5) * 0.1;
      
      foodLocations.add(FoodLocation(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_${foodLocations.length}',
        name: data['name'],
        address: data['address'],
        latitude: lat,
        longitude: lng,
        phone: data['phone'],
        description: 'Free food distribution and meal services',
        mealTypes: List<String>.from(data['mealTypes']),
        hours: data['hours'],
        requirements: List<String>.from(data['requirements']),
        acceptsFamilies: true,
        distance: _calculateDistance(lat, lng),
        rating: data['rating'],
        reviewCount: data['reviewCount'],
        organization: data['organization'],
      ));
    }
    
    return foodLocations;
  }

  /// Get personalized jobs based on user profile
  Future<List<JobListing>> getPersonalizedJobs(UserProfile? userProfile) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    List<JobListing> jobs = [];
    
    for (var data in _jobData) {
      final lat = 37.7749 + (_random.nextDouble() - 0.5) * 0.1;
      final lng = -122.4194 + (_random.nextDouble() - 0.5) * 0.1;
      
      jobs.add(JobListing(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_${jobs.length}',
        title: data['title'],
        company: data['company'],
        location: data['location'],
        latitude: lat,
        longitude: lng,
        description: data['description'],
        salary: data['salary'],
        employmentType: data['employmentType'],
        requirements: List<String>.from(data['requirements']),
        benefits: List<String>.from(data['benefits']),
        postedDate: _getRandomPostedDate(),
        applicationUrl: 'https://example.com/apply/${jobs.length}',
        distance: _calculateDistance(lat, lng),
        rating: data['rating'],
        reviewCount: data['reviewCount'],
        isEntryLevel: data['isEntryLevel'],
        requiresExperience: data['requiresExperience'],
        skills: List<String>.from(data['skills']),
      ));
    }
    
    // Personalize based on user profile
    if (userProfile != null) {
      jobs = _personalizeJobs(jobs, userProfile);
    }
    
    return jobs;
  }

  /// Personalize shelters based on user needs
  List<Shelter> _personalizeShelters(List<Shelter> shelters, UserProfile userProfile) {
    // Filter based on immediate needs
    if (userProfile.immediateNeeds != null) {
      if (userProfile.immediateNeeds!.contains('Shelter')) {
        // Prioritize emergency shelters
        shelters.sort((a, b) {
          if (a.services.contains('Emergency shelter') && !b.services.contains('Emergency shelter')) {
            return -1;
          } else if (!a.services.contains('Emergency shelter') && b.services.contains('Emergency shelter')) {
            return 1;
          }
          return 0;
        });
      }
    }
    
    // Filter based on family situation
    if (userProfile.situation != null && userProfile.situation!.toLowerCase().contains('family')) {
      shelters = shelters.where((s) => s.acceptsFamilies == true).toList();
    }
    
    return shelters;
  }

  /// Personalize jobs based on user profile
  List<JobListing> _personalizeJobs(List<JobListing> jobs, UserProfile userProfile) {
    // Filter based on education level
    if (userProfile.educationLevel != null) {
      final education = userProfile.educationLevel!.toLowerCase();
      if (education.contains('no formal') || education.contains('elementary')) {
        // Only show jobs that don't require education
        jobs = jobs.where((job) {
          return !job.description!.toLowerCase().contains('degree required') &&
                 !job.description!.toLowerCase().contains('college required');
        }).toList();
      }
    }
    
    // Filter based on skills
    if (userProfile.skills != null && userProfile.skills!.isNotEmpty) {
      jobs.sort((a, b) {
        final scoreA = _calculateJobScore(a, userProfile.skills!);
        final scoreB = _calculateJobScore(b, userProfile.skills!);
        return scoreB.compareTo(scoreA);
      });
    }
    
    // Prioritize entry-level jobs
    jobs.sort((a, b) {
      if (a.isEntryLevel == true && b.isEntryLevel != true) return -1;
      if (a.isEntryLevel != true && b.isEntryLevel == true) return 1;
      return 0;
    });
    
    return jobs;
  }

  /// Calculate job relevance score
  int _calculateJobScore(JobListing job, List<String> userSkills) {
    int score = 0;
    
    if (job.skills != null) {
      for (String jobSkill in job.skills!) {
        for (String userSkill in userSkills) {
          if (jobSkill.toLowerCase().contains(userSkill.toLowerCase()) ||
              userSkill.toLowerCase().contains(jobSkill.toLowerCase())) {
            score += 2;
          }
        }
      }
    }
    
    if (job.isEntryLevel == true) score += 1;
    if (job.requiresExperience == false) score += 1;
    
    return score;
  }

  /// Calculate distance from current location
  double? _calculateDistance(double lat, double lng) {
    if (_locationService.currentPosition == null) return null;
    
    return _locationService.calculateDistance(
      _locationService.currentPosition!.latitude,
      _locationService.currentPosition!.longitude,
      lat,
      lng,
    );
  }

  /// Get random posted date
  String _getRandomPostedDate() {
    final days = ['Today', 'Yesterday', '2 days ago', '3 days ago', '1 week ago'];
    return days[_random.nextInt(days.length)];
  }
}
