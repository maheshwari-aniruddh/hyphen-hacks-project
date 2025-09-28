// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shelter _$ShelterFromJson(Map<String, dynamic> json) => Shelter(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  phone: json['phone'] as String?,
  website: json['website'] as String?,
  description: json['description'] as String?,
  capacity: (json['capacity'] as num?)?.toInt(),
  availability: json['availability'] as String?,
  rules: (json['rules'] as List<dynamic>?)?.map((e) => e as String).toList(),
  services: (json['services'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  acceptsFamilies: json['acceptsFamilies'] as bool?,
  acceptsChildren: json['acceptsChildren'] as bool?,
  acceptsMen: json['acceptsMen'] as bool?,
  acceptsWomen: json['acceptsWomen'] as bool?,
  acceptsPets: json['acceptsPets'] as bool?,
  checkInTime: json['checkInTime'] as String?,
  checkOutTime: json['checkOutTime'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  reviewCount: (json['reviewCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$ShelterToJson(Shelter instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'phone': instance.phone,
  'website': instance.website,
  'description': instance.description,
  'capacity': instance.capacity,
  'availability': instance.availability,
  'rules': instance.rules,
  'services': instance.services,
  'acceptsFamilies': instance.acceptsFamilies,
  'acceptsChildren': instance.acceptsChildren,
  'acceptsMen': instance.acceptsMen,
  'acceptsWomen': instance.acceptsWomen,
  'acceptsPets': instance.acceptsPets,
  'checkInTime': instance.checkInTime,
  'checkOutTime': instance.checkOutTime,
  'rating': instance.rating,
  'reviewCount': instance.reviewCount,
};
