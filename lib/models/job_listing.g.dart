// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobListing _$JobListingFromJson(Map<String, dynamic> json) => JobListing(
  id: json['id'] as String,
  title: json['title'] as String,
  company: json['company'] as String,
  location: json['location'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  description: json['description'] as String?,
  salary: json['salary'] as String?,
  employmentType: json['employmentType'] as String?,
  requirements: (json['requirements'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  benefits: (json['benefits'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  postedDate: json['postedDate'] as String?,
  jobUrl: json['jobUrl'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  reviewCount: (json['reviewCount'] as num?)?.toInt(),
  isEntryLevel: json['isEntryLevel'] as bool?,
  requiresExperience: json['requiresExperience'] as bool?,
  skills: (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$JobListingToJson(JobListing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'company': instance.company,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'description': instance.description,
      'salary': instance.salary,
      'employmentType': instance.employmentType,
      'requirements': instance.requirements,
      'benefits': instance.benefits,
      'postedDate': instance.postedDate,
      'jobUrl': instance.jobUrl,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'isEntryLevel': instance.isEntryLevel,
      'requiresExperience': instance.requiresExperience,
      'skills': instance.skills,
    };
