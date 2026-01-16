enum HazardSeverity { low, medium, high, critical }

enum HazardStatus { reported, underInvestigation, resolved, closed }

class Hazard {
  final String id;
  final String workplaceId;
  final String title;
  final String description;
  final HazardSeverity severity;
  final HazardStatus status;
  final DateTime reportedDate;
  final String reportedBy;
  final DateTime? resolvedDate;
  final List<String> photoUrls;

  Hazard({
    required this.id,
    required this.workplaceId,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.reportedDate,
    required this.reportedBy,
    this.resolvedDate,
    this.photoUrls = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workplaceId': workplaceId,
      'title': title,
      'description': description,
      'severity': severity.index,
      'status': status.index,
      'reportedDate': reportedDate.toIso8601String(),
      'reportedBy': reportedBy,
      'resolvedDate': resolvedDate?.toIso8601String(),
      'photoUrls': photoUrls,
    };
  }

  factory Hazard.fromJson(Map<String, dynamic> json) {
    return Hazard(
      id: json['id'],
      workplaceId: json['workplaceId'],
      title: json['title'],
      description: json['description'],
      severity: HazardSeverity.values[json['severity']],
      status: HazardStatus.values[json['status']],
      reportedDate: DateTime.parse(json['reportedDate']),
      reportedBy: json['reportedBy'],
      resolvedDate: json['resolvedDate'] != null
          ? DateTime.parse(json['resolvedDate'])
          : null,
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
    );
  }
}
