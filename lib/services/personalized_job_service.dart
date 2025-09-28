import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../models/job_listing.dart';
import '../models/user_profile.dart';
import '../services/location_service.dart';
import '../services/onboarding_service.dart';

class PersonalizedJobService {
  static final PersonalizedJobService _instance = PersonalizedJobService._internal();
  factory PersonalizedJobService() => _instance;
  PersonalizedJobService._internal();

  final LocationService _locationService = LocationService();
  final OnboardingService _onboardingService = OnboardingService();
  
  UserProfile? _userProfile;

  /// Initialize with user profile
  Future<void> initialize() async {
    _userProfile = await _onboardingService.getUserProfile();
  }

  /// Get personalized job recommendations based on user profile
  Future<List<JobListing>> getPersonalizedJobs() async {
    await initialize();
    
    if (_userProfile == null) {
      return await _getFallbackJobs();
    }

    List<JobListing> allJobs = [];
    
    try {
      // Get jobs from multiple sources
      final indeedJobs = await _scrapeIndeedJobs();
      final zipRecruiterJobs = await _scrapeZipRecruiterJobs();
      final linkedinJobs = await _scrapeLinkedInJobs();
      final localJobs = await _scrapeLocalJobBoards();
      
      allJobs.addAll(indeedJobs);
      allJobs.addAll(zipRecruiterJobs);
      allJobs.addAll(linkedinJobs);
      allJobs.addAll(localJobs);
      
      // Personalize and filter jobs
      final personalizedJobs = _personalizeJobs(allJobs);
      
      // Sort by relevance score
      personalizedJobs.sort((a, b) {
        final scoreA = _calculateRelevanceScore(a);
        final scoreB = _calculateRelevanceScore(b);
        return scoreB.compareTo(scoreA);
      });
      
      return personalizedJobs.take(50).toList(); // Return top 50
    } catch (e) {
      print('Error getting personalized jobs: $e');
      return await _getFallbackJobs();
    }
  }

  /// Scrape Indeed for jobs
  Future<List<JobListing>> _scrapeIndeedJobs() async {
    try {
      final city = _getCurrentCity();
      final searchQueries = _generateSearchQueries();
      
      List<JobListing> jobs = [];
      
      for (String query in searchQueries) {
        final url = 'https://www.indeed.com/jobs?q=${Uri.encodeComponent(query)}&l=${Uri.encodeComponent(city)}&sort=date';
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
        );
        
        if (response.statusCode == 200) {
          final document = html_parser.parse(response.body);
          final jobElements = document.querySelectorAll('.job_seen_beacon');
          
          for (var element in jobElements) {
            final job = _parseIndeedJob(element);
            if (job != null) {
              jobs.add(job);
            }
          }
        }
        
        // Add delay to avoid rate limiting
        await Future.delayed(const Duration(seconds: 1));
      }
      
      return jobs;
    } catch (e) {
      print('Error scraping Indeed: $e');
      return [];
    }
  }

  /// Scrape ZipRecruiter for jobs
  Future<List<JobListing>> _scrapeZipRecruiterJobs() async {
    try {
      final city = _getCurrentCity();
      final searchQueries = _generateSearchQueries();
      
      List<JobListing> jobs = [];
      
      for (String query in searchQueries) {
        final url = 'https://www.ziprecruiter.com/jobs-search?search=${Uri.encodeComponent(query)}&location=${Uri.encodeComponent(city)}';
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
        );
        
        if (response.statusCode == 200) {
          final document = html_parser.parse(response.body);
          final jobElements = document.querySelectorAll('.job_content');
          
          for (var element in jobElements) {
            final job = _parseZipRecruiterJob(element);
            if (job != null) {
              jobs.add(job);
            }
          }
        }
        
        await Future.delayed(const Duration(seconds: 1));
      }
      
      return jobs;
    } catch (e) {
      print('Error scraping ZipRecruiter: $e');
      return [];
    }
  }

  /// Scrape LinkedIn for jobs
  Future<List<JobListing>> _scrapeLinkedInJobs() async {
    try {
      final city = _getCurrentCity();
      final searchQueries = _generateSearchQueries();
      
      List<JobListing> jobs = [];
      
      for (String query in searchQueries) {
        final url = 'https://www.linkedin.com/jobs/search/?keywords=${Uri.encodeComponent(query)}&location=${Uri.encodeComponent(city)}&sortBy=DD';
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
        );
        
        if (response.statusCode == 200) {
          final document = html_parser.parse(response.body);
          final jobElements = document.querySelectorAll('.job-search-card');
          
          for (var element in jobElements) {
            final job = _parseLinkedInJob(element);
            if (job != null) {
              jobs.add(job);
            }
          }
        }
        
        await Future.delayed(const Duration(seconds: 1));
      }
      
      return jobs;
    } catch (e) {
      print('Error scraping LinkedIn: $e');
      return [];
    }
  }

  /// Scrape local job boards
  Future<List<JobListing>> _scrapeLocalJobBoards() async {
    try {
      final city = _getCurrentCity();
      List<JobListing> jobs = [];
      
      // Scrape Craigslist jobs
      final craigslistJobs = await _scrapeCraigslistJobs(city);
      jobs.addAll(craigslistJobs);
      
      // Scrape local government jobs
      final govJobs = await _scrapeGovernmentJobs(city);
      jobs.addAll(govJobs);
      
      return jobs;
    } catch (e) {
      print('Error scraping local jobs: $e');
      return [];
    }
  }

  /// Scrape Craigslist for jobs
  Future<List<JobListing>> _scrapeCraigslistJobs(String city) async {
    try {
      final cityCode = _getCraigslistCityCode(city);
      final url = 'https://$cityCode.craigslist.org/search/jjj?query=entry+level&sort=date';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );
      
      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final jobElements = document.querySelectorAll('.result-row');
        
        List<JobListing> jobs = [];
        for (var element in jobElements) {
          final job = _parseCraigslistJob(element);
          if (job != null) {
            jobs.add(job);
          }
        }
        return jobs;
      }
    } catch (e) {
      print('Error scraping Craigslist: $e');
    }
    return [];
  }

  /// Scrape government jobs
  Future<List<JobListing>> _scrapeGovernmentJobs(String city) async {
    try {
      final url = 'https://www.usajobs.gov/Search/Results?k=entry+level&l=$city';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );
      
      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final jobElements = document.querySelectorAll('.usajobs-search-result');
        
        List<JobListing> jobs = [];
        for (var element in jobElements) {
          final job = _parseGovernmentJob(element);
          if (job != null) {
            jobs.add(job);
          }
        }
        return jobs;
      }
    } catch (e) {
      print('Error scraping government jobs: $e');
    }
    return [];
  }

  /// Generate personalized search queries based on user profile
  List<String> _generateSearchQueries() {
    if (_userProfile == null) {
      return ['entry level', 'no experience', 'trainee'];
    }

    List<String> queries = [];
    
    // Base queries for entry-level positions
    queries.addAll(['entry level', 'no experience required', 'trainee', 'junior']);
    
    // Add queries based on education level
    if (_userProfile!.educationLevel != null) {
      switch (_userProfile!.educationLevel!.toLowerCase()) {
        case 'no formal education':
        case 'elementary school':
          queries.addAll(['unskilled', 'general labor', 'warehouse', 'cleaning']);
          break;
        case 'high school':
          queries.addAll(['high school diploma', 'customer service', 'retail']);
          break;
        case 'some college':
        case 'college degree':
          queries.addAll(['college graduate', 'office work', 'administrative']);
          break;
      }
    }
    
    // Add queries based on skills
    if (_userProfile!.skills != null) {
      for (String skill in _userProfile!.skills!) {
        queries.add(skill.toLowerCase());
      }
    }
    
    // Add queries based on immediate needs
    if (_userProfile!.immediateNeeds != null) {
      if (_userProfile!.immediateNeeds!.contains('Job')) {
        queries.addAll(['immediate start', 'urgent hiring', 'asap']);
      }
    }
    
    return queries.take(10).toList(); // Limit to 10 queries
  }

  /// Personalize jobs based on user profile
  List<JobListing> _personalizeJobs(List<JobListing> jobs) {
    if (_userProfile == null) return jobs;
    
    return jobs.where((job) {
      // Filter based on education requirements
      if (_userProfile!.educationLevel != null) {
        final education = _userProfile!.educationLevel!.toLowerCase();
        if (education.contains('no formal') || education.contains('elementary')) {
          // Only show jobs that don't require education
          if (job.description?.toLowerCase().contains('degree required') == true ||
              job.description?.toLowerCase().contains('college required') == true) {
            return false;
          }
        }
      }
      
      // Filter based on experience requirements
      if (job.description?.toLowerCase().contains('years of experience') == true) {
        return false; // Skip jobs requiring experience
      }
      
      // Prioritize entry-level jobs
      if (job.isEntryLevel == false && job.requiresExperience == true) {
        return false;
      }
      
      return true;
    }).toList();
  }

  /// Calculate relevance score for job personalization
  double _calculateRelevanceScore(JobListing job) {
    if (_userProfile == null) return 0.0;
    
    double score = 0.0;
    
    // Base score for entry-level jobs
    if (job.isEntryLevel == true) score += 10.0;
    if (job.requiresExperience == false) score += 10.0;
    
    // Score based on skills match
    if (_userProfile!.skills != null && job.skills != null) {
      for (String userSkill in _userProfile!.skills!) {
        for (String jobSkill in job.skills!) {
          if (userSkill.toLowerCase().contains(jobSkill.toLowerCase()) ||
              jobSkill.toLowerCase().contains(userSkill.toLowerCase())) {
            score += 5.0;
          }
        }
      }
    }
    
    // Score based on education level
    if (_userProfile!.educationLevel != null) {
      final education = _userProfile!.educationLevel!.toLowerCase();
      if (education.contains('no formal') || education.contains('elementary')) {
        if (job.description?.toLowerCase().contains('no education required') == true) {
          score += 8.0;
        }
      }
    }
    
    // Score based on immediate needs
    if (_userProfile!.immediateNeeds != null) {
      if (_userProfile!.immediateNeeds!.contains('Job')) {
        if (job.description?.toLowerCase().contains('immediate') == true ||
            job.description?.toLowerCase().contains('urgent') == true) {
          score += 7.0;
        }
      }
    }
    
    return score;
  }

  // Parsing methods for different job sources
  JobListing? _parseIndeedJob(dynamic element) {
    try {
      final titleElement = element.querySelector('.jobTitle a');
      final companyElement = element.querySelector('.companyName');
      final locationElement = element.querySelector('.companyLocation');
      final salaryElement = element.querySelector('.salary-snippet');
      
      if (titleElement == null) return null;
      
      return JobListing(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_indeed',
        title: titleElement.text.trim(),
        company: companyElement?.text.trim() ?? 'Unknown Company',
        location: locationElement?.text.trim() ?? 'Location not specified',
        description: element.querySelector('.job-snippet')?.text.trim(),
        salary: salaryElement?.text.trim(),
        employmentType: 'Full-time',
        postedDate: _parseDate(element.querySelector('.date')?.text.trim()),
        applicationUrl: 'https://indeed.com${titleElement.attributes['href']}',
        isEntryLevel: _isEntryLevel(titleElement.text.trim()),
        requiresExperience: _requiresExperience(element.text),
        skills: _extractSkills(element.text),
      );
    } catch (e) {
      print('Error parsing Indeed job: $e');
      return null;
    }
  }

  JobListing? _parseZipRecruiterJob(dynamic element) {
    try {
      final titleElement = element.querySelector('.job_title a');
      final companyElement = element.querySelector('.company_name');
      final locationElement = element.querySelector('.location');
      
      if (titleElement == null) return null;
      
      return JobListing(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_ziprecruiter',
        title: titleElement.text.trim(),
        company: companyElement?.text.trim() ?? 'Unknown Company',
        location: locationElement?.text.trim() ?? 'Location not specified',
        description: element.querySelector('.job_description')?.text.trim(),
        employmentType: 'Full-time',
        postedDate: 'Recently',
        applicationUrl: titleElement.attributes['href'],
        isEntryLevel: _isEntryLevel(titleElement.text.trim()),
        requiresExperience: _requiresExperience(element.text),
        skills: _extractSkills(element.text),
      );
    } catch (e) {
      print('Error parsing ZipRecruiter job: $e');
      return null;
    }
  }

  JobListing? _parseLinkedInJob(dynamic element) {
    try {
      final titleElement = element.querySelector('.base-search-card__title a');
      final companyElement = element.querySelector('.base-search-card__subtitle');
      final locationElement = element.querySelector('.job-search-card__location');
      
      if (titleElement == null) return null;
      
      return JobListing(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_linkedin',
        title: titleElement.text.trim(),
        company: companyElement?.text.trim() ?? 'Unknown Company',
        location: locationElement?.text.trim() ?? 'Location not specified',
        description: element.querySelector('.base-search-card__snippet')?.text.trim(),
        employmentType: 'Full-time',
        postedDate: 'Recently',
        applicationUrl: 'https://linkedin.com${titleElement.attributes['href']}',
        isEntryLevel: _isEntryLevel(titleElement.text.trim()),
        requiresExperience: _requiresExperience(element.text),
        skills: _extractSkills(element.text),
      );
    } catch (e) {
      print('Error parsing LinkedIn job: $e');
      return null;
    }
  }

  JobListing? _parseCraigslistJob(dynamic element) {
    try {
      final titleElement = element.querySelector('.result-title');
      final locationElement = element.querySelector('.result-hood');
      
      if (titleElement == null) return null;
      
      return JobListing(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_craigslist',
        title: titleElement.text.trim(),
        company: 'Local Business',
        location: locationElement?.text.trim() ?? 'Local Area',
        description: element.querySelector('.result-snippet')?.text.trim(),
        employmentType: 'Part-time',
        postedDate: _parseDate(element.querySelector('.result-date')?.text.trim()),
        applicationUrl: titleElement.attributes['href'],
        isEntryLevel: true,
        requiresExperience: false,
        skills: _extractSkills(element.text),
      );
    } catch (e) {
      print('Error parsing Craigslist job: $e');
      return null;
    }
  }

  JobListing? _parseGovernmentJob(dynamic element) {
    try {
      final titleElement = element.querySelector('.usajobs-search-result--core__title a');
      final agencyElement = element.querySelector('.usajobs-search-result--core__agency');
      final locationElement = element.querySelector('.usajobs-search-result--core__location');
      
      if (titleElement == null) return null;
      
      return JobListing(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_government',
        title: titleElement.text.trim(),
        company: agencyElement?.text.trim() ?? 'U.S. Government',
        location: locationElement?.text.trim() ?? 'Various Locations',
        description: element.querySelector('.usajobs-search-result--core__summary')?.text.trim(),
        employmentType: 'Full-time',
        postedDate: 'Recently',
        applicationUrl: 'https://usajobs.gov${titleElement.attributes['href']}',
        isEntryLevel: _isEntryLevel(titleElement.text.trim()),
        requiresExperience: _requiresExperience(element.text),
        skills: _extractSkills(element.text),
      );
    } catch (e) {
      print('Error parsing government job: $e');
      return null;
    }
  }

  // Helper methods
  bool _isEntryLevel(String title) {
    final lowerTitle = title.toLowerCase();
    return lowerTitle.contains('entry') || 
           lowerTitle.contains('junior') || 
           lowerTitle.contains('assistant') ||
           lowerTitle.contains('trainee') ||
           lowerTitle.contains('no experience');
  }

  bool _requiresExperience(String text) {
    final lowerText = text.toLowerCase();
    return lowerText.contains('years of experience') ||
           lowerText.contains('experience required') ||
           lowerText.contains('minimum experience');
  }

  List<String> _extractSkills(String text) {
    List<String> skills = [];
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('customer service')) skills.add('Customer service');
    if (lowerText.contains('communication')) skills.add('Communication');
    if (lowerText.contains('computer')) skills.add('Computer skills');
    if (lowerText.contains('teamwork')) skills.add('Teamwork');
    if (lowerText.contains('problem solving')) skills.add('Problem solving');
    if (lowerText.contains('time management')) skills.add('Time management');
    
    return skills;
  }

  String _parseDate(String? dateString) {
    if (dateString == null) return 'Recently';
    
    if (dateString.contains('today')) return 'Today';
    if (dateString.contains('yesterday')) return 'Yesterday';
    if (dateString.contains('days ago')) return dateString;
    
    return 'Recently';
  }

  String _getCurrentCity() {
    // This would get the current city from location service
    return 'San Francisco, CA'; // Default for demo
  }

  String _getCraigslistCityCode(String city) {
    // Map cities to Craigslist codes
    final cityMap = {
      'San Francisco': 'sfbay',
      'Los Angeles': 'losangeles',
      'New York': 'newyork',
      'Chicago': 'chicago',
      'Houston': 'houston',
      'Phoenix': 'phoenix',
      'Philadelphia': 'philadelphia',
      'San Antonio': 'sanantonio',
      'San Diego': 'sandiego',
      'Dallas': 'dallas',
    };
    
    return cityMap[city] ?? 'sfbay';
  }

  Future<List<JobListing>> _getFallbackJobs() async {
    // Return some basic fallback jobs if scraping fails
    return [
      JobListing(
        id: 'fallback_1',
        title: 'Warehouse Worker',
        company: 'Local Distribution Center',
        location: 'Various Locations',
        description: 'Entry-level warehouse position with on-the-job training',
        salary: '\$15-18/hour',
        employmentType: 'Full-time',
        requirements: ['No experience required', 'Must be able to lift 50 lbs'],
        benefits: ['Health insurance', 'Paid time off'],
        postedDate: 'Recently',
        applicationUrl: 'https://example.com/apply',
        isEntryLevel: true,
        requiresExperience: false,
        skills: ['Physical labor', 'Teamwork'],
      ),
    ];
  }
}
