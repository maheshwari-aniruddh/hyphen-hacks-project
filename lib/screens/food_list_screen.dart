import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/food_location.dart';
import '../services/apify_data_service.dart';
import '../models/user_profile.dart';
import '../services/onboarding_service.dart';
import '../widgets/glass_widgets.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final ApifyDataService _apifyDataService = ApifyDataService();
  final OnboardingService _onboardingService = OnboardingService();
  
  List<FoodLocation> _foodLocations = [];
  bool _isLoading = true;
  String _searchQuery = '';
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _onboardingService.getUserProfile();
      final foodLocations = await _apifyDataService.getPersonalizedFoodLocations(profile);
      
      setState(() {
        _userProfile = profile;
        _foodLocations = foodLocations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading food locations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<FoodLocation> get _filteredFoodLocations {
    if (_searchQuery.isEmpty) return _foodLocations;
    
    return _foodLocations.where((location) {
      final query = _searchQuery.toLowerCase();
      return location.name.toLowerCase().contains(query) ||
             location.address.toLowerCase().contains(query) ||
             (location.description?.toLowerCase().contains(query) ?? false) ||
             (location.organization?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Food Locations'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildPersonalizedHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildFoodLocationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search food locations by name, address, or organization...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildPersonalizedHeader() {
    if (_userProfile == null) return const SizedBox.shrink();

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food assistance for your needs',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Free meals and food pantries in San Francisco',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodLocationList() {
    if (_filteredFoodLocations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty 
                  ? 'No food locations available'
                  : 'No food locations found for "$_searchQuery"',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or check back later',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredFoodLocations.length,
      itemBuilder: (context, index) {
        final location = _filteredFoodLocations[index];
        return _buildFoodLocationCard(location);
      },
    );
  }

  Widget _buildFoodLocationCard(FoodLocation location) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (location.rating != null && location.rating! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location.rating!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (location.description != null && location.description!.isNotEmpty)
            Text(
              location.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
                height: 1.4,
              ),
            ),
          const SizedBox(height: 12),
          _buildFoodLocationDetails(location),
          const SizedBox(height: 16),
          _buildActionButtons(location),
        ],
      ),
    );
  }

  Widget _buildFoodLocationDetails(FoodLocation location) {
    return Column(
      children: [
        if (location.phone != null && location.phone != 'N/A')
          _buildDetailRow(Icons.phone, 'Phone', location.phone!),
        if (location.hours != null)
          _buildDetailRow(Icons.schedule, 'Hours', location.hours!),
        if (location.days != null)
          _buildDetailRow(Icons.calendar_today, 'Days', location.days!),
        if (location.organization != null)
          _buildDetailRow(Icons.business, 'Organization', location.organization!),
        if (location.contactPerson != null)
          _buildDetailRow(Icons.person, 'Contact', location.contactPerson!),
        if (location.capacity != null)
          _buildDetailRow(Icons.people, 'Capacity', '${location.capacity} people'),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(FoodLocation location) {
    return Row(
      children: [
        if (location.phone != null && location.phone != 'N/A')
          Expanded(
            child: GlassButton(
              onPressed: () => _callLocation(location.phone!),
              backgroundColor: Colors.green.withOpacity(0.8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, size: 16),
                  SizedBox(width: 8),
                  Text('Call'),
                ],
              ),
            ),
          ),
        if (location.phone != null && location.phone != 'N/A')
          const SizedBox(width: 12),
        if (location.website != null && location.website != 'N/A')
          Expanded(
            child: GlassButton(
              onPressed: () => _openWebsite(location.website!),
              backgroundColor: Colors.blue.withOpacity(0.8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.web, size: 16),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Website',
                      style: TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassButton(
            onPressed: () => _showLocationDetails(location),
            backgroundColor: const Color(0xFF6366F1).withOpacity(0.8),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info, size: 16),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Details',
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _callLocation(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not make phone call'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openWebsite(String website) async {
    final uri = Uri.parse(website.startsWith('http') ? website : 'https://$website');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open website'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLocationDetails(FoodLocation location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(location.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (location.description != null)
                Text(location.description!),
              const SizedBox(height: 16),
              if (location.mealTypes != null && location.mealTypes!.isNotEmpty) ...[
                const Text(
                  'Meal Types:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...location.mealTypes!.map((meal) => Text('• $meal')),
                const SizedBox(height: 16),
              ],
              if (location.dietaryOptions != null && location.dietaryOptions!.isNotEmpty) ...[
                const Text(
                  'Dietary Options:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...location.dietaryOptions!.map((option) => Text('• $option')),
                const SizedBox(height: 16),
              ],
              if (location.requiresId != null) ...[
                const Text(
                  'Requirements:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('• ID Required: ${location.requiresId! ? "Yes" : "No"}'),
                if (location.requiresReservation != null)
                  Text('• Reservation Required: ${location.requiresReservation! ? "Yes" : "No"}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}