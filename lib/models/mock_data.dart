import 'package:flutter/material.dart';

class Shelter {
  final String name;
  final String address;
  final String phone;
  final String description;

  Shelter({
    required this.name,
    required this.address,
    required this.phone,
    required this.description,
  });
}

class FoodLocation {
  final String name;
  final String address;
  final String phone;
  final String description;

  FoodLocation({
    required this.name,
    required this.address,
    required this.phone,
    required this.description,
  });
}

class JobListing {
  final String title;
  final String company;
  final String location;
  final String description;

  JobListing({
    required this.title,
    required this.company,
    required this.location,
    required this.description,
  });
}

class MockData {
  static List<Shelter> getShelters() {
    return [
      Shelter(
        name: "Hope Shelter",
        address: "123 Main St, Downtown",
        phone: "(555) 123-4567",
        description: "Emergency shelter with meals and beds",
      ),
      Shelter(
        name: "Grace House",
        address: "456 Oak Ave, Midtown",
        phone: "(555) 234-5678",
        description: "Family shelter with childcare services",
      ),
      Shelter(
        name: "Safe Haven",
        address: "789 Pine St, Uptown",
        phone: "(555) 345-6789",
        description: "Women and children shelter",
      ),
    ];
  }

  static List<FoodLocation> getFoodLocations() {
    return [
      FoodLocation(
        name: "Community Kitchen",
        address: "321 Elm St, Downtown",
        phone: "(555) 456-7890",
        description: "Free meals daily 6-8 PM",
      ),
      FoodLocation(
        name: "Food Bank",
        address: "654 Maple Ave, Midtown",
        phone: "(555) 567-8901",
        description: "Food pantry open Mon-Fri 9-5",
      ),
      FoodLocation(
        name: "Soup Kitchen",
        address: "987 Cedar St, Uptown",
        phone: "(555) 678-9012",
        description: "Hot meals served daily",
      ),
    ];
  }

  static List<JobListing> getJobs() {
    return [
      JobListing(
        title: "Kitchen Helper",
        company: "Local Restaurant",
        location: "Downtown",
        description: "Part-time kitchen work, no experience required",
      ),
      JobListing(
        title: "Janitor",
        company: "Office Building",
        location: "Midtown",
        description: "Cleaning position, flexible hours",
      ),
      JobListing(
        title: "Day Laborer",
        company: "Construction Co",
        location: "Various",
        description: "General construction work",
      ),
    ];
  }
}
