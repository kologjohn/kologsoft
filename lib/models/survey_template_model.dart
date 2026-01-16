import 'survey_question_model.dart';

class SurveyTemplate {
  final String id;
  final String name;
  final String workspaceClass;
  final DateTime createdAt;

  SurveyTemplate({
    required this.id,
    required this.name,
    required this.workspaceClass,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'workspaceClass': workspaceClass,
    'createdAt': createdAt,
  };

  factory SurveyTemplate.fromMap(Map<String, dynamic> map) {
    return SurveyTemplate(
      id: map['id'],
      name: map['name'],
      workspaceClass: map['workspaceClass'],
      createdAt: map['createdAt'].toDate(),
    );
  }
}
