import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../models/job_listing.dart';
import 'location_service.dart';

class JobService {
  static final JobService _instance = JobService._internal();
  factory JobService() => _instance;
  JobService._internal();

  final LocationService _locationService = LocationService();
  
  // Mock data for demonstration - in a real app, this would come from Google Jobs API or web scraping
  final List<JobListing> _mockJobListings = [
    JobListing(
      id: '1',
      title: 'Warehouse Worker',
      company: 'ABC Logistics',
      location: 'Downtown',
      description: 'Entry-level warehouse position with on-the-job training',
      salary: '\$15-18/hour',
      employmentType: 'Full-time',



      requirements: ['No experience required', 'Must be able to lift 50 lbs'],
      benefits: ['Health insurance', 'Paid time off', '401k'],
      postedDate: '2 days ago',
      applicationUrl: 'https://abclogistics.com/careers',
      isEntryLevel: true,
      requiresExperience: false,
      skills: ['Physical labor', 'Teamwork'],
      rating: 3.8,
      reviewCount: 23,
    ),
    JobListing(
      id: '2',
      title: 'Food Service Worker',
      company: 'City Diner',
      location: 'Midtown',
      description: 'Kitchen helper and server position',
      salary: '\$12-15/hour + tips',
      employmentType: 'Part-time',
      requirements: ['Food handler permit preferred', 'Customer service skills'],
      benefits: ['Flexible schedule', 'Free meals'],
      postedDate: '1 day ago',
      applicationUrl: 'https://citydiner.com/jobs',
      isEntryLevel: true,
      requiresExperience: false,
      skills: ['Customer service', 'Food preparation'],
      rating: 4.1,
      reviewCount: 15,
    ),
    JobListing(
      id: '3',
      title: 'Janitorial Staff',
      company: 'CleanCorp',
      location: 'Various locations',
      description: 'Cleaning positions at various office buildings',
      salary: '\$14-16/hour',
      employmentType: 'Full-time',
      requirements: ['Reliable transportation', 'Background check'],
      benefits: ['Health insurance', 'Uniforms provided'],
      postedDate: '3 days ago',
      applicationUrl: 'https://cleancorp.com/careers',
      isEntryLevel: true,
      requiresExperience: false,
      skills: ['Cleaning', 'Attention to detail'],
      rating: 3.9,
      reviewCount: 31,
    ),
    JobListing(
      id: '4',
      title: 'Retail Associate',
      company: 'QuickMart',
      location: 'Uptown',
      description: 'Cashier and stock clerk position',
      salary: '\$13-16/hour',
      employmentType: 'Part-time',
      requirements: ['Basic math skills', 'Customer service'],
      benefits: ['Employee discount', 'Flexible hours'],
      postedDate: '1 day ago',
      applicationUrl: 'https://quickmart.com/jobs',
      isEntryLevel: true,
      requiresExperience: false,
      skills: ['Cash handling', 'Customer service'],
      rating: 4.0,
      reviewCount: 42,
    ),
    JobListing(
      id: '5',
      title: 'Construction Helper',
      company: 'BuildRight Construction',
      location: 'Various job sites',
      description: 'Entry-level construction work with training',
      salary: '\$16-20/hour',
      employmentType: 'Full-time',
      requirements: ['Valid driver\'s license', 'Physical fitness'],
      benefits: ['Health insurance', 'Tool allowance', 'Overtime pay'],
      postedDate: '4 days ago',
      applicationUrl: 'https://buildright.com/careers',
      isEntryLevel: true,
      requiresExperience: false,
      skills: ['Physical labor', 'Construction basics'],
      rating: 4.2,
      reviewCount: 18,
    ),
  ];

  /// Get all job listings
  Future<List<JobListing>> getAllJobListings() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_mockJobListings);
  }

  /// Get nearby job listings within specified radius
  Future<List<JobListing>> getNearbyJobListings({double radiusInMiles = 25.0}) async {
    List<JobListing> allJobs = await getAllJobListings();
    
    if (_locationService.currentPosition == null) {
      await _locationService.getCurrentLocation();
    }

    if (_locationService.currentPosition == null) {
      return allJobs; // Return all if location not available
    }

    // For demo purposes, we'll add mock distances
    return allJobs.map((job) {
      // Generate a random distance within the radius for demo
      double distance = (radiusInMiles * (0.1 + (job.hashCode % 100) / 100));
      
      return JobListing(
        id: job.id,
        title: job.title,
        company: job.company,
        location: job.location,
        description: job.description,
        salary: job.salary,
        employmentType: job.employmentType,
        requirements: job.requirements,
        benefits: job.benefits,
        postedDate: job.postedDate,
        applicationUrl: job.applicationUrl,
        companyWebsite: job.companyWebsite,
        distance: distance,
        rating: job.rating,
        reviewCount: job.reviewCount,
        isEntryLevel: job.isEntryLevel,
        requiresExperience: job.requiresExperience,
        skills: job.skills,
      );
    }).toList();
  }

  /// Search job listings by title, company, or skills
  Future<List<JobListing>> searchJobListings(String query) async {
    List<JobListing> allJobs = await getAllJobListings();
    
    if (query.isEmpty) return allJobs;

    String lowercaseQuery = query.toLowerCase();
    
    return allJobs.where((job) {
      return job.title.toLowerCase().contains(lowercaseQuery) ||
             job.company.toLowerCase().contains(lowercaseQuery) ||
             job.description?.toLowerCase().contains(lowercaseQuery) == true ||
             job.skills?.any((skill) => skill.toLowerCase().contains(lowercaseQuery)) == true;
    }).toList();
  }

  /// Filter job listings by criteria
  Future<List<JobListing>> filterJobListings({
    bool? isEntryLevel,
    bool? requiresExperience,
    String? employmentType,
    double? minSalary,
    double? maxDistance,
    List<String>? requiredSkills,
  }) async {
    List<JobListing> jobs = await getNearbyJobListings(radiusInMiles: maxDistance ?? 50.0);

    return jobs.where((job) {
      if (isEntryLevel != null && job.isEntryLevel != isEntryLevel) {
        return false;
      }
      if (requiresExperience != null && job.requiresExperience != requiresExperience) {
        return false;
      }
      if (employmentType != null && job.employmentType != employmentType) {
        return false;
      }
      if (minSalary != null && job.salary != null) {
        // Extract numeric value from salary string (simplified)
        RegExp salaryRegex = RegExp(r'\$(\d+)');
        Match? match = salaryRegex.firstMatch(job.salary!);
        if (match != null) {
          double salary = double.tryParse(match.group(1)!) ?? 0;
          if (salary < minSalary) return false;
        }
      }
      if (requiredSkills != null && requiredSkills.isNotEmpty) {
        bool hasAllSkills = requiredSkills.every((skill) =>
            job.skills?.any((jobSkill) =>
                jobSkill.toLowerCase().contains(skill.toLowerCase())) == true);
        if (!hasAllSkills) return false;
      }
      return true;
    }).toList();
  }

  /// Get job listing details by ID
  Future<JobListing?> getJobListingById(String id) async {
    List<JobListing> jobs = await getAllJobListings();
    try {
      return jobs.firstWhere((job) => job.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get entry-level jobs (suitable for people without experience)
  Future<List<JobListing>> getEntryLevelJobs() async {
    return await filterJobListings(isEntryLevel: true, requiresExperience: false);
  }

  /// Get jobs that don't require experience
  Future<List<JobListing>> getJobsNoExperienceRequired() async {
    return await filterJobListings(requiresExperience: false);
  }

  /// Get jobs by employment type
  Future<List<JobListing>> getJobsByType(String employmentType) async {
    return await filterJobListings(employmentType: employmentType);
  }

  /// Scrape Google Jobs (placeholder - would need actual implementation)
  Future<List<JobListing>> scrapeGoogleJobs(String query, {String? location}) async {
    // This is a placeholder implementation
    // In a real app, you would:
    // 1. Make HTTP requests to Google Jobs
    // 2. Parse the HTML response
    // 3. Extract job information
    // 4. Convert to JobListing objects
    
    print('Scraping Google Jobs for: $query in $location');
    
    // For now, return filtered mock data based on query
    List<JobListing> allJobs = await getAllJobListings();
    return allJobs.where((job) {
      String searchQuery = query.toLowerCase();
      return job.title.toLowerCase().contains(searchQuery) ||
             job.description?.toLowerCase().contains(searchQuery) == true;
    }).toList();
  }

  /// Get jobs suitable for user's skills and situation
  Future<List<JobListing>> getRecommendedJobs(List<String> userSkills, String educationLevel) async {
    List<JobListing> allJobs = await getAllJobListings();
    
    // Filter jobs based on user's education level
    List<JobListing> suitableJobs = allJobs.where((job) {
      // For people with no formal education, prioritize entry-level jobs
      if (educationLevel.toLowerCase().contains('none') || educationLevel.toLowerCase().contains('high school')) {
        return job.isEntryLevel == true && job.requiresExperience == false;
      }
      return true;
    }).toList();

    // Score jobs based on skill matches
    suitableJobs.sort((a, b) {
      int scoreA = _calculateJobScore(a, userSkills);
      int scoreB = _calculateJobScore(b, userSkills);
      return scoreB.compareTo(scoreA);
    });

    return suitableJobs;
  }

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
    
    // Bonus points for entry-level jobs
    if (job.isEntryLevel == true) score += 1;
    if (job.requiresExperience == false) score += 1;
    
    return score;
  }
}

