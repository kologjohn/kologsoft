import 'package:cloud_firestore/cloud_firestore.dart';

class ModeModel {
  final String id;
  final String modeName;
  final int modeQuantity;
  final Map<String, Map<String, dynamic>> pricingRules;

  final String companyId;
  final String company;
  final String createdBy;
  final DateTime createdAt;

  ModeModel({
    required this.id,
    required this.modeName,
    required this.modeQuantity,
    required this.pricingRules,
    required this.companyId,
    required this.company,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'modeName': modeName,
      'modeQuantity': modeQuantity,
      'pricingRules': pricingRules,
      'companyid': companyId,
      'company': company,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ModeModel.fromMap(Map<String, dynamic> map) {
    return ModeModel(
      id: map['id'] ?? '',
      modeName: map['modename'] ?? '',
      modeQuantity: (map['modeQuantity'] ?? 0).toInt(),
      pricingRules:
      Map<String, Map<String, dynamic>>.from(map['pricingrules'] ?? {}),
      companyId: map['companyid'] ?? '',
      company: map['company'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
