import 'package:json_annotation/json_annotation.dart';

part 'food_location.g.dart';

@JsonSerializable()
class FoodLocation {
  final String id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? website;
  final String? description;
  final List<String>? mealTypes;
  final String? hours;
  final String? days;
  final bool? requiresId;
  final bool? requiresReservation;
  final int? capacity;
  final List<String>? dietaryOptions;
  final double? rating;
  final int? reviewCount;
  final String? organization;
  final String? contactPerson;

  FoodLocation({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.phone,
    this.website,
    this.description,
    this.mealTypes,
    this.hours,
    this.days,
    this.requiresId,
    this.requiresReservation,
    this.capacity,
    this.dietaryOptions,
    this.rating,
    this.reviewCount,
    this.organization,
    this.contactPerson,
  });

  factory FoodLocation.fromJson(Map<String, dynamic> json) => _$FoodLocationFromJson(json);
  Map<String, dynamic> toJson() => _$FoodLocationToJson(this);
}