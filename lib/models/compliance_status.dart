enum ComplianceStatus {
  green, // Both certificates valid
  yellow, // Factory valid, H&S expired
  orange, // H&S valid, Factory expired
  red, // Both expired
}

extension ComplianceStatusExtension on ComplianceStatus {
  String get description {
    switch (this) {
      case ComplianceStatus.green:
        return 'Both certificates valid';
      case ComplianceStatus.yellow:
        return 'Factory valid, H&S expired';
      case ComplianceStatus.orange:
        return 'H&S valid, Factory expired';
      case ComplianceStatus.red:
        return 'Both expired';
    }
  }

  int get colorValue {
    switch (this) {
      case ComplianceStatus.green:
        return 0xFF4CAF50;
      case ComplianceStatus.yellow:
        return 0xFFFFEB3B;
      case ComplianceStatus.orange:
        return 0xFFFF9800;
      case ComplianceStatus.red:
        return 0xFFF44336;
    }
  }
}
