import 'package:cloud_firestore/cloud_firestore.dart';

class WorkspaceRegistration {
  final String id;
  final String name;
  final String registrationNumber;
  final String businessType;
  final String workspaceClass;
  final String address;
  final String contactPerson;
  final String phone;
  final String email;
  final String regionCode;
  final String regionName;
  final String constituencyCode;
  final String constituencyName;
  final String electoralArea;
  final double latitude;
  final double longitude;
  final Timestamp registrationDate;
  final String? userEmail;
  final String? userDisplayName;

  WorkspaceRegistration({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.businessType,
    required this.workspaceClass,
    required this.address,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.regionCode,
    required this.regionName,
    required this.constituencyCode,
    required this.constituencyName,
    required this.electoralArea,
    required this.latitude,
    required this.longitude,
    required this.registrationDate,
    this.userEmail,
    this.userDisplayName,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'registrationNumber': registrationNumber,
    'businessType': businessType,
    'workspaceClass': workspaceClass,
    'address': address,
    'contactPerson': contactPerson,
    'phone': phone,
    'email': email,
    'regionCode': regionCode,
    'regionName': regionName,
    'constituencyCode': constituencyCode,
    'constituencyName': constituencyName,
    'electoralArea': electoralArea,
    'latitude': latitude,
    'longitude': longitude,
    'registrationDate': registrationDate,
    'userEmail': userEmail,
    'userDisplayName': userDisplayName,
  };

  factory WorkspaceRegistration.fromMap(Map<String, dynamic> map) =>
      WorkspaceRegistration(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        registrationNumber: map['registrationNumber'] ?? '',
        businessType: map['businessType'] ?? '',
        workspaceClass: map['workspaceClass'] ?? '',
        address: map['address'] ?? '',
        contactPerson: map['contactPerson'] ?? '',
        phone: map['phone'] ?? '',
        email: map['email'] ?? '',
        regionCode: map['regionCode'] ?? '',
        regionName: map['regionName'] ?? '',
        constituencyCode: map['constituencyCode'] ?? '',
        constituencyName: map['constituencyName'] ?? '',
        electoralArea: map['electoralArea'] ?? '',
        latitude: (map['latitude'] ?? 0).toDouble(),
        longitude: (map['longitude'] ?? 0).toDouble(),
        registrationDate: map['registrationDate'] ?? Timestamp.now(),
        userEmail: map['userEmail'],
        userDisplayName: map['userDisplayName'],
      );

  factory WorkspaceRegistration.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkspaceRegistration(
      id: doc.id,
      name: data['name'] ?? '',
      registrationNumber: data['registrationNumber'] ?? '',
      businessType: data['businessType'] ?? '',
      workspaceClass: data['workspaceClass'] ?? '',
      address: data['address'] ?? '',
      contactPerson: data['contactPerson'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      regionCode: data['regionCode'] ?? '',
      regionName: data['regionName'] ?? '',
      constituencyCode: data['constituencyCode'] ?? '',
      constituencyName: data['constituencyName'] ?? '',
      electoralArea: data['electoralArea'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      registrationDate: data['registrationDate'] ?? Timestamp.now(),
      userEmail: data['userEmail'],
      userDisplayName: data['userDisplayName'],
    );
  }
}
