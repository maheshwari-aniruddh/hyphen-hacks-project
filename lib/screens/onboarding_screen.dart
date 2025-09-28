import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/onboarding_service.dart';
import '../widgets/glass_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingService _onboardingService = OnboardingService();
  
  int _currentPage = 0;
  bool _isLoading = false;

  // Form data - simplified to 5 steps
  String _name = '';
  String _age = '';
  String _gender = '';
  String _homelessnessLevel = '';
  String _education = '';
  String _employmentStatus = '';
  List<String> _physicalConditions = [];

  final List<String> _pageTitles = [
    'Welcome to nxt.home',
    'Basic Information',
    'Your Situation',
    'Education & Work',
    'Health & Physical'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFFEC4899),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildBasicInfoPage(),
                    _buildSituationPage(),
                    _buildEducationWorkPage(),
                    _buildHealthPage(),
                  ],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            _pageTitles[_currentPage],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentPage + 1) / _pageTitles.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_currentPage + 1} of ${_pageTitles.length}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.favorite,
              size: 80,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to nxt.home',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'We\'re here to help you find shelter, food, and job opportunities in San Francisco. Let\'s get to know you better.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'This will only take 2 minutes and will help us connect you with the right resources.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField('Full Name', _name, (value) => _name = value),
            const SizedBox(height: 16),
            _buildTextField('Age', _age, (value) => _age = value),
            const SizedBox(height: 16),
            _buildDropdownField(
              'Gender',
              _gender,
              ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
              (value) => _gender = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSituationPage() {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Situation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            _buildDropdownField(
              'What is your housing situation?',
              _homelessnessLevel,
              [
                'Less than 1 month',
                '1-3 months',
                '3-6 months',
                '6-12 months',
                '1-2 years',
                'More than 2 years',
                'Currently housed'
              ],
              (value) => _homelessnessLevel = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationWorkPage() {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Education & Work',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            _buildDropdownField(
              'Education Level',
              _education,
              [
                'No formal education',
                'Elementary',
                'High School',
                'Some College',
                'Associate Degree',
                'Bachelor\'s Degree',
                'Master\'s Degree',
                'Doctorate'
              ],
              (value) => _education = value,
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              'Employment Status',
              _employmentStatus,
              [
                'Unemployed',
                'Part-time',
                'Full-time',
                'Self-employed',
                'Student',
                'Retired',
                'Disabled'
              ],
              (value) => _employmentStatus = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthPage() {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health & Physical Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Do you have any physical conditions or disabilities? (Select all that apply)',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            _buildMultiSelectChips([
              'None',
              'Mobility issues',
              'Vision problems',
              'Hearing problems',
              'Mental health conditions',
              'Chronic illness',
              'Physical disability',
              'Other'
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
          ),
          items: options.map((option) => DropdownMenuItem(
            value: option,
            child: Text(option),
          )).toList(),
          onChanged: (newValue) => onChanged(newValue ?? ''),
        ),
      ],
    );
  }

  Widget _buildMultiSelectChips(List<String> options) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = _physicalConditions.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _physicalConditions.add(option);
              } else {
                _physicalConditions.remove(option);
              }
            });
          },
          backgroundColor: Colors.white.withOpacity(0.8),
          selectedColor: const Color(0xFF6366F1).withOpacity(0.2),
          checkmarkColor: const Color(0xFF6366F1),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: GlassButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('Previous'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: GlassButton(
              onPressed: _currentPage == _pageTitles.length - 1 ? _completeOnboarding : _nextPage,
              child: Text(_currentPage == _pageTitles.length - 1 ? 'Complete' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProfile = UserProfile(
        name: _name,
        age: _age,
        gender: _gender,
        familyStatus: '',
        education: _education,
        skills: [],
        experience: '',
        immediateNeeds: [],
        location: 'San Francisco, CA',
        phoneNumber: '',
        email: '',
        emergencyContact: '',
        emergencyPhone: '',
        healthConditions: _physicalConditions,
        employmentStatus: _employmentStatus,
        housingStatus: _homelessnessLevel,
        incomeSource: '',
        transportation: '',
        barriers: [],
        goals: '',
        preferredJobType: '',
        workSchedule: '',
        salaryExpectation: '',
        certifications: [],
        languages: '',
        specialNeeds: '',
        notes: '',
      );

      await _onboardingService.saveUserProfile(userProfile);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}