enum InspectionType { factory, healthAndSafety }

enum InspectionStatus { scheduled, inProgress, completed, approved, rejected }

class Inspection {
  final String id;
  final String workplaceId;
  final InspectionType type;
  final InspectionStatus status;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String inspectorId;
  final String inspectorName;
  final double? latitude;
  final double? longitude;
  final List<String> photoUrls;
  final String? findings;
  final bool? passed;
  final String? supervisorComments;

  Inspection({
    required this.id,
    required this.workplaceId,
    required this.type,
    required this.status,
    required this.scheduledDate,
    this.completedDate,
    required this.inspectorId,
    required this.inspectorName,
    this.latitude,
    this.longitude,
    this.photoUrls = const [],
    this.findings,
    this.passed,
    this.supervisorComments,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workplaceId': workplaceId,
      'type': type.index,
      'status': status.index,
      'scheduledDate': scheduledDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'inspectorId': inspectorId,
      'inspectorName': inspectorName,
      'latitude': latitude,
      'longitude': longitude,
      'photoUrls': photoUrls,
      'findings': findings,
      'passed': passed,
      'supervisorComments': supervisorComments,
    };
  }

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'],
      workplaceId: json['workplaceId'],
      type: InspectionType.values[json['type']],
      status: InspectionStatus.values[json['status']],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      inspectorId: json['inspectorId'],
      inspectorName: json['inspectorName'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
      findings: json['findings'],
      passed: json['passed'],
      supervisorComments: json['supervisorComments'],
    );
  }
}
