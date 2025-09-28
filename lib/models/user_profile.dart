import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String name;
  final String age;
  final String gender;
  final String familyStatus;
  final String education;
  final List<String> skills;
  final String experience;
  final List<String> immediateNeeds;
  final String location;
  final String phoneNumber;
  final String email;
  final String emergencyContact;
  final String emergencyPhone;
  final List<String> healthConditions;
  final String employmentStatus;
  final String housingStatus;
  final String incomeSource;
  final String transportation;
  final List<String> barriers;
  final String goals;
  final String preferredJobType;
  final String workSchedule;
  final String salaryExpectation;
  final List<String> certifications;
  final String languages;
  final String specialNeeds;
  final String notes;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.familyStatus,
    required this.education,
    required this.skills,
    required this.experience,
    required this.immediateNeeds,
    required this.location,
    required this.phoneNumber,
    required this.email,
    required this.emergencyContact,
    required this.emergencyPhone,
    required this.healthConditions,
    required this.employmentStatus,
    required this.housingStatus,
    required this.incomeSource,
    required this.transportation,
    required this.barriers,
    required this.goals,
    required this.preferredJobType,
    required this.workSchedule,
    required this.salaryExpectation,
    required this.certifications,
    required this.languages,
    required this.specialNeeds,
    required this.notes,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}