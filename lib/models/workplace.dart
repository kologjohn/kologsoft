
import 'business_category.dart';
import 'compliance_status.dart';

class Workplace {
  final String id;
  final String name;
  final String registrationNumber;
  final BusinessCategory category;
  final String address;
  final String contactPerson;
  final String phoneNumber;
  final String email;
  final DateTime registrationDate;
  final ComplianceStatus complianceStatus;
  final DateTime? factoryExpiryDate;
  final DateTime? hsExpiryDate;
  final double latitude;
  final double longitude;

  Workplace({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.category,
    required this.address,
    required this.contactPerson,
    required this.phoneNumber,
    required this.email,
    required this.registrationDate,
    required this.complianceStatus,
    this.factoryExpiryDate,
    this.hsExpiryDate,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'registrationNumber': registrationNumber,
      'category': category.index,
      'address': address,
      'contactPerson': contactPerson,
      'phoneNumber': phoneNumber,
      'email': email,
      'registrationDate': registrationDate.toIso8601String(),
      'complianceStatus': complianceStatus.index,
      'factoryExpiryDate': factoryExpiryDate?.toIso8601String(),
      'hsExpiryDate': hsExpiryDate?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Workplace.fromJson(Map<String, dynamic> json) {
    return Workplace(
      id: json['id'],
      name: json['name'],
      registrationNumber: json['registrationNumber'],
      category: BusinessCategory.values[json['category']],
      address: json['address'],
      contactPerson: json['contactPerson'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      registrationDate: DateTime.parse(json['registrationDate']),
      complianceStatus: ComplianceStatus.values[json['complianceStatus']],
      factoryExpiryDate: json['factoryExpiryDate'] != null
          ? DateTime.parse(json['factoryExpiryDate'])
          : null,
      hsExpiryDate: json['hsExpiryDate'] != null
          ? DateTime.parse(json['hsExpiryDate'])
          : null,
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Workplace copyWith({
    String? id,
    String? name,
    String? registrationNumber,
    BusinessCategory? category,
    String? address,
    String? contactPerson,
    String? phoneNumber,
    String? email,
    DateTime? registrationDate,
    ComplianceStatus? complianceStatus,
    DateTime? factoryExpiryDate,
    DateTime? hsExpiryDate,
    double? latitude,
    double? longitude,
  }) {
    return Workplace(
      id: id ?? this.id,
      name: name ?? this.name,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      category: category ?? this.category,
      address: address ?? this.address,
      contactPerson: contactPerson ?? this.contactPerson,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      registrationDate: registrationDate ?? this.registrationDate,
      complianceStatus: complianceStatus ?? this.complianceStatus,
      factoryExpiryDate: factoryExpiryDate ?? this.factoryExpiryDate,
      hsExpiryDate: hsExpiryDate ?? this.hsExpiryDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
