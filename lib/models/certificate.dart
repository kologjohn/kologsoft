enum CertificateType { factory, healthAndSafety }

class Certificate {
  final String id;
  final String workplaceId;
  final CertificateType type;
  final String certificateNumber;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String qrCode;
  final bool isValid;
  final String invoiceId;
  final String inspectionId;

  Certificate({
    required this.id,
    required this.workplaceId,
    required this.type,
    required this.certificateNumber,
    required this.issueDate,
    required this.expiryDate,
    required this.qrCode,
    required this.isValid,
    required this.invoiceId,
    required this.inspectionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workplaceId': workplaceId,
      'type': type.index,
      'certificateNumber': certificateNumber,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'qrCode': qrCode,
      'isValid': isValid,
      'invoiceId': invoiceId,
      'inspectionId': inspectionId,
    };
  }

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      workplaceId: json['workplaceId'],
      type: CertificateType.values[json['type']],
      certificateNumber: json['certificateNumber'],
      issueDate: DateTime.parse(json['issueDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      qrCode: json['qrCode'],
      isValid: json['isValid'],
      invoiceId: json['invoiceId'],
      inspectionId: json['inspectionId'],
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiryDate);
}
