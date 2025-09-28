// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  name: json['name'] as String,
  age: json['age'] as String,
  gender: json['gender'] as String,
  familyStatus: json['familyStatus'] as String,
  education: json['education'] as String,
  skills: (json['skills'] as List<dynamic>).map((e) => e as String).toList(),
  experience: json['experience'] as String,
  immediateNeeds: (json['immediateNeeds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  location: json['location'] as String,
  phoneNumber: json['phoneNumber'] as String,
  email: json['email'] as String,
  emergencyContact: json['emergencyContact'] as String,
  emergencyPhone: json['emergencyPhone'] as String,
  healthConditions: (json['healthConditions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  employmentStatus: json['employmentStatus'] as String,
  housingStatus: json['housingStatus'] as String,
  incomeSource: json['incomeSource'] as String,
  transportation: json['transportation'] as String,
  barriers: (json['barriers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  goals: json['goals'] as String,
  preferredJobType: json['preferredJobType'] as String,
  workSchedule: json['workSchedule'] as String,
  salaryExpectation: json['salaryExpectation'] as String,
  certifications: (json['certifications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  languages: json['languages'] as String,
  specialNeeds: json['specialNeeds'] as String,
  notes: json['notes'] as String,
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'familyStatus': instance.familyStatus,
      'education': instance.education,
      'skills': instance.skills,
      'experience': instance.experience,
      'immediateNeeds': instance.immediateNeeds,
      'location': instance.location,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'emergencyContact': instance.emergencyContact,
      'emergencyPhone': instance.emergencyPhone,
      'healthConditions': instance.healthConditions,
      'employmentStatus': instance.employmentStatus,
      'housingStatus': instance.housingStatus,
      'incomeSource': instance.incomeSource,
      'transportation': instance.transportation,
      'barriers': instance.barriers,
      'goals': instance.goals,
      'preferredJobType': instance.preferredJobType,
      'workSchedule': instance.workSchedule,
      'salaryExpectation': instance.salaryExpectation,
      'certifications': instance.certifications,
      'languages': instance.languages,
      'specialNeeds': instance.specialNeeds,
      'notes': instance.notes,
    };
