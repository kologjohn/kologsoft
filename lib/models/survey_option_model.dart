import 'package:cloud_firestore/cloud_firestore.dart';

class SurveyOption {
  final String label;
  final int weight;

  SurveyOption({
    required this.label,
    required this.weight,
  });

  Map<String, dynamic> toMap() => {
    'label': label,
    'weight': weight,
  };

  factory SurveyOption.fromMap(Map<String, dynamic> map) {
    return SurveyOption(
      label: map['label'],
      weight: map['weight'],
    );
  }
}
