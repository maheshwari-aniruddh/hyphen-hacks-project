import 'package:json_annotation/json_annotation.dart';

part 'shelter.g.dart';

@JsonSerializable()
class Shelter {
  final String id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? website;
  final String? description;
  final int? capacity;
  final String? availability;
  final List<String>? rules;
  final List<String>? services;
  final bool? acceptsFamilies;
  final bool? acceptsChildren;
  final bool? acceptsMen;
  final bool? acceptsWomen;
  final bool? acceptsPets;
  final String? checkInTime;
  final String? checkOutTime;
  final double? rating;
  final int? reviewCount;

  Shelter({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.phone,
    this.website,
    this.description,
    this.capacity,
    this.availability,
    this.rules,
    this.services,
    this.acceptsFamilies,
    this.acceptsChildren,
    this.acceptsMen,
    this.acceptsWomen,
    this.acceptsPets,
    this.checkInTime,
    this.checkOutTime,
    this.rating,
    this.reviewCount,
  });

  factory Shelter.fromJson(Map<String, dynamic> json) => _$ShelterFromJson(json);
  Map<String, dynamic> toJson() => _$ShelterToJson(this);
}