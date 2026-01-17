import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel {
  String id;
  String company;
  String companyid;
  String name;
  String phone;
  String email;
  String address;
  String branch;
  String type;
  String logo;

  DateTime createdAt;
  DateTime updatedAt;
  String updatedBy;

  CompanyModel({
    required this.id,
    required this.company,
    required this.companyid,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.branch,
    required this.logo,
    required this.createdAt,
    required this.updatedAt,
    required this.updatedBy,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company': company,
      'companyid': companyid,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'branch': branch,
      'logo': logo,
      'createdat': Timestamp.fromDate(createdAt),
      'updatedat': Timestamp.fromDate(updatedAt),
      'updatedby': updatedBy,
      'type': type,
    };
  }

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      id: map['id'],
      company: map['company'],
      companyid: map['companyid'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      branch: map['branch'],
      type: map['type'],
      logo: map['logo'] ?? '',
      createdAt: (map['createdat'] as Timestamp).toDate(),
      updatedAt: (map['updatedat'] as Timestamp).toDate(),
      updatedBy: map['updatedby'] ?? '',
    );
  }
}
