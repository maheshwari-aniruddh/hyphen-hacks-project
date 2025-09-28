import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/job_listing.dart';
import '../services/apify_data_service.dart';
import '../models/user_profile.dart';
import '../services/onboarding_service.dart';
import '../widgets/glass_widgets.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final ApifyDataService _apifyDataService = ApifyDataService();
  final OnboardingService _onboardingService = OnboardingService();
  
  List<JobListing> _jobs = [];
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
      final jobs = await _apifyDataService.getPersonalizedJobs(profile);
      
      setState(() {
        _userProfile = profile;
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading jobs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<JobListing> get _filteredJobs {
    if (_searchQuery.isEmpty) return _jobs;
    
    return _jobs.where((job) {
      final query = _searchQuery.toLowerCase();
      return job.title.toLowerCase().contains(query) ||
             job.company.toLowerCase().contains(query) ||
             job.location.toLowerCase().contains(query) ||
             (job.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Opportunities'),
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
                : _buildJobList(),
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
          hintText: 'Search jobs by title, company, or location...',
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

    String personalizedMessage = '';
    if (_userProfile!.employmentStatus == 'Unemployed') {
      personalizedMessage = 'We found entry-level jobs perfect for you!';
    } else if (_userProfile!.education.contains('High School')) {
      personalizedMessage = 'Great opportunities for high school graduates!';
    } else if (_userProfile!.education.contains('College')) {
      personalizedMessage = 'Professional opportunities matching your education!';
    } else {
      personalizedMessage = 'Job opportunities in San Francisco!';
    }

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personalizedMessage,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on your ${_userProfile!.education} education',
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
          if (_userProfile!.employmentStatus == 'Unemployed') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'All jobs shown are entry-level friendly',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJobList() {
    if (_filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty 
                  ? 'No job opportunities available'
                  : 'No jobs found for "$_searchQuery"',
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
      itemCount: _filteredJobs.length,
      itemBuilder: (context, index) {
        final job = _filteredJobs[index];
        return _buildJobCard(job);
      },
    );
  }

  Widget _buildJobCard(JobListing job) {
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
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${job.company} • ${job.location}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (job.rating != null && job.rating! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job.rating!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (job.description != null && job.description!.isNotEmpty)
            Text(
              job.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 12),
          _buildJobDetails(job),
          const SizedBox(height: 16),
          _buildActionButtons(job),
        ],
      ),
    );
  }

  Widget _buildJobDetails(JobListing job) {
    return Column(
      children: [
        if (job.salary != null)
          _buildDetailRow(Icons.attach_money, 'Salary', job.salary!),
        if (job.employmentType != null)
          _buildDetailRow(Icons.schedule, 'Type', job.employmentType!),
        if (job.postedDate != null)
          _buildDetailRow(Icons.calendar_today, 'Posted', job.postedDate!),
        if (job.isEntryLevel != null && job.isEntryLevel!)
          _buildDetailRow(Icons.school, 'Level', 'Entry Level'),
        if (job.reviewCount != null && job.reviewCount! > 0)
          _buildDetailRow(Icons.reviews, 'Reviews', '${job.reviewCount} reviews'),
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

  Widget _buildActionButtons(JobListing job) {
    return Row(
      children: [
        if (job.jobUrl != null && job.jobUrl!.isNotEmpty)
          Expanded(
            child: GlassButton(
              onPressed: () => _applyForJob(job.jobUrl!),
              backgroundColor: Colors.green.withOpacity(0.8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 16),
                  SizedBox(width: 8),
                  Text('Apply'),
                ],
              ),
            ),
          ),
        if (job.jobUrl != null && job.jobUrl!.isNotEmpty)
          const SizedBox(width: 12),
        Expanded(
          child: GlassButton(
            onPressed: () => _showJobDetails(job),
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

  Future<void> _applyForJob(String jobUrl) async {
    final uri = Uri.parse(jobUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open job application'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showJobDetails(JobListing job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(job.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${job.company} • ${job.location}'),
              const SizedBox(height: 16),
              if (job.description != null)
                Text(job.description!),
              const SizedBox(height: 16),
              if (job.requirements != null && job.requirements!.isNotEmpty) ...[
                const Text(
                  'Requirements:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...job.requirements!.map((req) => Text('• $req')),
                const SizedBox(height: 16),
              ],
              if (job.benefits != null && job.benefits!.isNotEmpty) ...[
                const Text(
                  'Benefits:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...job.benefits!.map((benefit) => Text('• $benefit')),
                const SizedBox(height: 16),
              ],
              if (job.skills != null && job.skills!.isNotEmpty) ...[
                const Text(
                  'Required Skills:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: job.skills!.map((skill) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (job.jobUrl != null && job.jobUrl!.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _applyForJob(job.jobUrl!);
              },
              child: const Text('Apply Now'),
            ),
        ],
      ),
    );
  }
}