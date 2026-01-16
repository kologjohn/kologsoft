import 'package:cloud_firestore/cloud_firestore.dart';

class Supplier {
  final String id;
  final String name;
  final String supplier;
  final String contact;
  final String company;
  final String staff;
  final String companyid;
  final Timestamp datecreated;

  Supplier({
    required this.id,
    required this.name,
    required this.supplier,
    required this.staff,
    required this.contact,
    required this.company,
    required this.companyid,
    required this.datecreated,
  });

  // Convert
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'staff': staff,
    'supplier': supplier,
    'contact': contact,
    'company': company,
    'companyid': companyid,
    'datecreated': datecreated,
  };

  // Create object from Firestore Map
  factory Supplier.fromMap(Map<String, dynamic> map) => Supplier(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    staff: map['staff'] ?? '',
    supplier: map['supplier'] ?? '',
    contact: map['contact'] ?? '',
    company: map['company'] ?? '',
    companyid: map['companyid'] ?? '',
    datecreated: map['datecreated'] ?? Timestamp.now(),
  );
}
