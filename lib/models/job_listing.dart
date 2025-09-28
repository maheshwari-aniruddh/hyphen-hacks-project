import 'package:json_annotation/json_annotation.dart';

part 'job_listing.g.dart';

@JsonSerializable()
class JobListing {
  final String id;
  final String title;
  final String company;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String? salary;
  final String? employmentType;
  final List<String>? requirements;
  final List<String>? benefits;
  final String? postedDate;
  final String? jobUrl;
  final double? rating;
  final int? reviewCount;
  final bool? isEntryLevel;
  final bool? requiresExperience;
  final List<String>? skills;

  JobListing({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    this.latitude,
    this.longitude,
    this.description,
    this.salary,
    this.employmentType,
    this.requirements,
    this.benefits,
    this.postedDate,
    this.jobUrl,
    this.rating,
    this.reviewCount,
    this.isEntryLevel,
    this.requiresExperience,
    this.skills,
  });

  factory JobListing.fromJson(Map<String, dynamic> json) => _$JobListingFromJson(json);
  Map<String, dynamic> toJson() => _$JobListingToJson(this);
}