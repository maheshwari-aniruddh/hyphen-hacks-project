import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/shelter.dart';
import '../services/apify_data_service.dart';
import '../models/user_profile.dart';
import '../services/onboarding_service.dart';
import '../widgets/glass_widgets.dart';

class ShelterListScreen extends StatefulWidget {
  const ShelterListScreen({super.key});

  @override
  State<ShelterListScreen> createState() => _ShelterListScreenState();
}

class _ShelterListScreenState extends State<ShelterListScreen> {
  final ApifyDataService _apifyDataService = ApifyDataService();
  final OnboardingService _onboardingService = OnboardingService();
  
  List<Shelter> _shelters = [];
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
      final shelters = await _apifyDataService.getPersonalizedShelters(profile);
      
      setState(() {
        _userProfile = profile;
        _shelters = shelters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading shelters: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Shelter> get _filteredShelters {
    if (_searchQuery.isEmpty) return _shelters;
    
    return _shelters.where((shelter) {
      final query = _searchQuery.toLowerCase();
      return shelter.name.toLowerCase().contains(query) ||
             shelter.address.toLowerCase().contains(query) ||
             (shelter.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Shelters'),
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
                : _buildShelterList(),
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
          hintText: 'Search shelters by name, address, or description...',
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
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shelters matching your needs',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on your ${_userProfile!.housingStatus} situation',
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

  Widget _buildShelterList() {
    if (_filteredShelters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty 
                  ? 'No shelters available'
                  : 'No shelters found for "$_searchQuery"',
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
      itemCount: _filteredShelters.length,
      itemBuilder: (context, index) {
        final shelter = _filteredShelters[index];
        return _buildShelterCard(shelter);
      },
    );
  }

  Widget _buildShelterCard(Shelter shelter) {
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
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.home,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shelter.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shelter.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (shelter.rating != null && shelter.rating! > 0)
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
                        shelter.rating!.toStringAsFixed(1),
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
          if (shelter.description != null && shelter.description!.isNotEmpty)
            Text(
              shelter.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
                height: 1.4,
              ),
            ),
          const SizedBox(height: 12),
          _buildShelterDetails(shelter),
          const SizedBox(height: 16),
          _buildActionButtons(shelter),
        ],
      ),
    );
  }

  Widget _buildShelterDetails(Shelter shelter) {
    return Column(
      children: [
        if (shelter.phone != null && shelter.phone != 'N/A')
          _buildDetailRow(Icons.phone, 'Phone', shelter.phone!),
        if (shelter.availability != null)
          _buildDetailRow(Icons.schedule, 'Availability', shelter.availability!),
        if (shelter.capacity != null)
          _buildDetailRow(Icons.people, 'Capacity', '${shelter.capacity} beds'),
        if (shelter.checkInTime != null)
          _buildDetailRow(Icons.login, 'Check-in', shelter.checkInTime!),
        if (shelter.checkOutTime != null)
          _buildDetailRow(Icons.logout, 'Check-out', shelter.checkOutTime!),
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

  Widget _buildActionButtons(Shelter shelter) {
    return Row(
      children: [
        if (shelter.phone != null && shelter.phone != 'N/A')
          Expanded(
            child: GlassButton(
              onPressed: () => _callShelter(shelter.phone!),
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
        if (shelter.phone != null && shelter.phone != 'N/A')
          const SizedBox(width: 12),
        if (shelter.website != null && shelter.website != 'N/A')
          Expanded(
            child: GlassButton(
              onPressed: () => _openWebsite(shelter.website!),
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
            onPressed: () => _showShelterDetails(shelter),
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

  Future<void> _callShelter(String phoneNumber) async {
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

  void _showShelterDetails(Shelter shelter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(shelter.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (shelter.description != null)
                Text(shelter.description!),
              const SizedBox(height: 16),
              if (shelter.services != null && shelter.services!.isNotEmpty) ...[
                const Text(
                  'Services:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...shelter.services!.map((service) => Text('• $service')),
                const SizedBox(height: 16),
              ],
              if (shelter.rules != null && shelter.rules!.isNotEmpty) ...[
                const Text(
                  'Rules:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...shelter.rules!.map((rule) => Text('• $rule')),
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