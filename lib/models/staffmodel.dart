import 'package:cloud_firestore/cloud_firestore.dart';

class StaffModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String accesslevel;
  final String branch;
  final String branchid;
  final List<String> pricingmode;
  final Map<String, Timestamp>? readUpdates;
  final Timestamp createdAt;
  final String createdBy;
  final Timestamp? deletedAt;
  final String? deletedBy;
  final String companyId;
  final String company;
  final int position;

  StaffModel({
    this.id = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.accesslevel = '',
    this.branch = '',
    this.branchid = '',
    this.pricingmode = const [],
    this.readUpdates,
    required this.createdAt,
    required this.company,
    this.createdBy = '',
    this.deletedAt,
    this.deletedBy,
    this.companyId = '',
    this.position = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'branch': branch,
    'branchid': branchid,
    'pricingMode': pricingmode,
    'readUpdates': readUpdates,
    'createdAt': createdAt,
    'createdBy': createdBy,
    'deletedAt': deletedAt,
    'deletedBy': deletedBy,
    'companyId': companyId,
    'position': position,
    'company': company,
  };

  factory StaffModel.fromMap(Map<String, dynamic> map) {
    Timestamp parseTimestamp(dynamic v) {
      if (v == null) return Timestamp.now();
      if (v is Timestamp) return v;
      if (v is String) {
        try {
          return Timestamp.fromDate(DateTime.parse(v));
        } catch (_) {
          return Timestamp.now();
        }
      }
      if (v is DateTime) return Timestamp.fromDate(v);
      return Timestamp.now();
    }

    List<String> parsePricing(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v is String)
        return v
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      return [v.toString()];
    }

    Map<String, Timestamp>? parseReadUpdates(dynamic v) {
      if (v == null) return null;
      if (v is Map) {
        final result = <String, Timestamp>{};
        v.forEach((key, value) {
          if (value is Timestamp) {
            result[key.toString()] = value;
          } else if (value is String) {
            try {
              result[key.toString()] = Timestamp.fromDate(
                DateTime.parse(value),
              );
            } catch (_) {}
          } else if (value is DateTime) {
            result[key.toString()] = Timestamp.fromDate(value);
          }
        });
        return result;
      }
      return null;
    }

    return StaffModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      company: map['company'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      accesslevel: map['accesslevel'] ?? '',
      branch: map['branch'] ?? '',
      branchid: map['branchid'] ?? '',
      pricingmode: parsePricing(map['pricingMode'] ?? map['pricingmode']),
      readUpdates: parseReadUpdates(
        map['readUpdates'] ?? map['read_updates'] ?? map['read'],
      ),
      createdAt: parseTimestamp(
        map['createdAt'] ?? map['date'] ?? map['createdAt'],
      ),
      createdBy: map['createdBy'] ?? map['createdby'] ?? '',
      deletedAt: map['deletedAt'] != null
          ? parseTimestamp(map['deletedAt'])
          : null,
      deletedBy: map['deletedBy'] ?? map['deletedby'],
      companyId: map['companyId'] ?? map['companyId'] ?? '',
      position: map['position'] ?? 0,
    );
  }
}
