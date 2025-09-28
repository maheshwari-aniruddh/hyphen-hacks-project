import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/shelter.dart';
import '../models/food_location.dart';
import '../models/job_listing.dart';
import '../services/shelter_service.dart';
import '../services/food_service.dart';
import '../services/job_service.dart';
import '../services/location_service.dart';
import '../models/user_profile.dart';
import '../services/onboarding_service.dart';
import '../services/apify_data_service.dart';
import 'shelter_list_screen.dart';
import 'food_list_screen.dart';
import 'job_list_screen.dart';
import 'map_screen.dart';
import '../widgets/glass_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ShelterService _shelterService = ShelterService();
  final FoodService _foodService = FoodService();
  final JobService _jobService = JobService();
  final ApifyDataService _apifyDataService = ApifyDataService();
  final LocationService _locationService = LocationService();
  final OnboardingService _onboardingService = OnboardingService();

  List<Shelter> _nearbyShelters = [];
  List<FoodLocation> _nearbyFood = [];
  List<JobListing> _nearbyJobs = [];
  bool _isLoading = true;
  String? _userName;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserProfile();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Request location permission
      bool hasLocation = await _locationService.requestLocationPermission();
      
      // Load real data from Apify
      final shelters = await _apifyDataService.getRealShelters(_userProfile);
      final food = await _apifyDataService.getRealFoodLocations(_userProfile);
      final jobs = await _apifyDataService.getRealJobs(_userProfile);

      setState(() {
        _nearbyShelters = shelters.take(3).toList();
        _nearbyFood = food.take(3).toList();
        _nearbyJobs = jobs.take(3).toList();
      });
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    final profile = await _onboardingService.getUserProfile();
    if (profile != null) {
      setState(() {
        _userProfile = profile;
        _userName = profile.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_userName != null ? 'Welcome, $_userName!' : 'nxt.home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                _resetOnboarding();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Text('Reset Profile'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PersonalizedWelcomeCard(
                      userName: _userName,
                      immediateNeeds: _userProfile?.immediateNeeds,
                      situation: _userProfile?.situation,
                    ),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildPersonalizedRecommendations(),
                    const SizedBox(height: 24),
                    _buildNearbyShelters(),
                    const SizedBox(height: 24),
                    _buildNearbyFood(),
                    const SizedBox(height: 24),
                    _buildNearbyJobs(),
                    const SizedBox(height: 24),
                    _buildEmergencyResources(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickActions() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.home_work,
                  label: 'Find Shelters',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShelterListScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.restaurant,
                  label: 'Find Food',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FoodListScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.work,
                  label: 'Find Jobs',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const JobListScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.map,
                  label: 'View Map',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapScreen(mapType: 'all')),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedRecommendations() {
    if (_userProfile == null) return const SizedBox.shrink();
    
    List<String> recommendations = [];
    
    // Based on housing situation level
    if (_userProfile!.housingStatus.contains('Less than 1 month') || 
        _userProfile!.housingStatus.contains('1-3 months')) {
      recommendations.add('🚨 Emergency shelter available - St. Anthony\'s has immediate beds');
    }
    
    // Based on employment status
    if (_userProfile!.employmentStatus == 'Unemployed') {
      recommendations.add('💼 Entry-level jobs available - SFMTA hiring customer service reps');
    }
    
    // Based on education level
    if (_userProfile!.education.contains('High School') || 
        _userProfile!.education.contains('Some College')) {
      recommendations.add('🎓 Consider SF City College - Free tuition for residents');
    }
    
    // Based on physical conditions
    if (_userProfile!.healthConditions.contains('Mobility issues')) {
      recommendations.add('♿ Accessible shelters available - Hamilton Families has wheelchair access');
    }
    
    // Based on family status
    if (_userProfile!.familyStatus.contains('With Children')) {
      recommendations.add('👨‍👩‍👧‍👦 Family shelters available - Compass Family Services');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('🌟 Check out our job listings - Great opportunities in SF!');
    }
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Personalized Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recommendations.take(3).map((recommendation) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1F2937),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GlassButton(
      onPressed: onTap,
      backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
      foregroundColor: const Color(0xFF6366F1),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6366F1),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyShelters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nearby Shelters',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShelterListScreen()),
              ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_nearbyShelters.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No nearby shelters found. Tap "Find Shelters" to see all available options.'),
            ),
          )
        else
          ..._nearbyShelters.map((shelter) => _buildShelterCard(shelter)),
      ],
    );
  }

  Widget _buildShelterCard(Shelter shelter) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    shelter.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (shelter.distance != null)
                  Text(
                    '${shelter.distance!.toStringAsFixed(1)} mi',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              shelter.address,
              style: const TextStyle(color: Colors.grey),
            ),
            if (shelter.phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _makePhoneCall(shelter.phone),
                    child: Text(shelter.phone),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: shelter.services.take(3).map((service) => Chip(
                label: Text(service, style: const TextStyle(fontSize: 12)),
                backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyFood() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nearby Food',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FoodListScreen()),
              ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_nearbyFood.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No nearby food locations found. Tap "Find Food" to see all available options.'),
            ),
          )
        else
          ..._nearbyFood.map((food) => _buildFoodCard(food)),
      ],
    );
  }

  Widget _buildFoodCard(FoodLocation food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (food.distance != null)
                  Text(
                    '${food.distance!.toStringAsFixed(1)} mi',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              food.address,
              style: const TextStyle(color: Colors.grey),
            ),
            if (food.hours != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    food.hours!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: food.mealTypes.take(3).map((mealType) => Chip(
                label: Text(mealType, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.green.withOpacity(0.1),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyJobs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nearby Jobs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JobListScreen()),
              ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_nearbyJobs.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No nearby jobs found. Tap "Find Jobs" to see all available opportunities.'),
            ),
          )
        else
          ..._nearbyJobs.map((job) => _buildJobCard(job)),
      ],
    );
  }

  Widget _buildJobCard(JobListing job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (job.distance != null)
                  Text(
                    '${job.distance!.toStringAsFixed(1)} mi',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              job.company,
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              job.location,
              style: const TextStyle(color: Colors.grey),
            ),
            if (job.salary != null) ...[
              const SizedBox(height: 8),
              Text(
                job.salary!,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (job.applicationUrl != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _launchUrl(job.applicationUrl!),
                  child: const Text('Apply Now'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyResources() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Resources',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            _buildEmergencyButton(
              'Call 911',
              Icons.emergency,
              Colors.red,
              () => _makePhoneCall('911'),
            ),
            const SizedBox(height: 12),
            _buildEmergencyButton(
              'National Suicide Prevention Lifeline',
              Icons.psychology,
              Colors.orange,
              () => _makePhoneCall('988'),
            ),
            const SizedBox(height: 12),
            _buildEmergencyButton(
              'Crisis Text Line',
              Icons.message,
              Colors.blue,
              () => _makePhoneCall('741741'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _showLocationInfo() async {
    if (_locationService.currentPosition == null) {
      await _locationService.getCurrentLocation();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location Enabled: ${_locationService.isLocationEnabled}'),
            if (_locationService.currentPosition != null) ...[
              const SizedBox(height: 8),
              Text('Latitude: ${_locationService.currentPosition!.latitude.toStringAsFixed(4)}'),
              Text('Longitude: ${_locationService.currentPosition!.longitude.toStringAsFixed(4)}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!_locationService.isLocationEnabled)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _locationService.requestLocationPermission();
              },
              child: const Text('Enable Location'),
            ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _resetOnboarding() async {
    // Show confirmation dialog
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Profile'),
        content: const Text('Are you sure you want to reset your profile? This will clear all your information and start the onboarding process again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (shouldReset == true) {
      await _onboardingService.resetOnboarding();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/onboarding',
          (route) => false,
        );
      }
    }
  }
}
