import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String accessLevel;
  final String region;
  final String email;
  final Timestamp date;
  final String createdBy;
  final String phone;

  AppUser({
    required this.id,
    required this.name,
    required this.accessLevel,
    required this.region,
    required this.email,
    required this.date,
    required this.createdBy,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'accessLevel': accessLevel,
      'region': region,
      'email': email,
      'date': date,
      'createdBy': createdBy,
      'phone': phone,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String docId) {
    return AppUser(
      id: docId,
      name: map['name'] ?? '',
      accessLevel: map['accessLevel'] ?? '',
      region: map['region'] ?? '',
      email: map['email'] ?? '',
      date: map['date'] as Timestamp,
      createdBy: map['createdBy'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}
