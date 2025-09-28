// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodLocation _$FoodLocationFromJson(Map<String, dynamic> json) => FoodLocation(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  phone: json['phone'] as String?,
  website: json['website'] as String?,
  description: json['description'] as String?,
  mealTypes: (json['mealTypes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  hours: json['hours'] as String?,
  days: json['days'] as String?,
  requiresId: json['requiresId'] as bool?,
  requiresReservation: json['requiresReservation'] as bool?,
  capacity: (json['capacity'] as num?)?.toInt(),
  dietaryOptions: (json['dietaryOptions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  rating: (json['rating'] as num?)?.toDouble(),
  reviewCount: (json['reviewCount'] as num?)?.toInt(),
  organization: json['organization'] as String?,
  contactPerson: json['contactPerson'] as String?,
);

Map<String, dynamic> _$FoodLocationToJson(FoodLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phone': instance.phone,
      'website': instance.website,
      'description': instance.description,
      'mealTypes': instance.mealTypes,
      'hours': instance.hours,
      'days': instance.days,
      'requiresId': instance.requiresId,
      'requiresReservation': instance.requiresReservation,
      'capacity': instance.capacity,
      'dietaryOptions': instance.dietaryOptions,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'organization': instance.organization,
      'contactPerson': instance.contactPerson,
    };
