import 'survey_option_model.dart';

enum SurveyQuestionType {
  singleChoice,
  multipleChoice,
  number,
  file,
}

class SurveyQuestion {
  final String id;
  final String question;
  final SurveyQuestionType type;
  final List<SurveyOption> options;
  final List<Map<String, int>> numberRules;
  final int fileWeight;

  SurveyQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options = const [],
    this.numberRules = const [],
    this.fileWeight = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'question': question,
    'type': type.name,
    'options': options.map((e) => e.toMap()).toList(),
    'numberRules': numberRules,
    'fileWeight': fileWeight,
  };

  factory SurveyQuestion.fromMap(Map<String, dynamic> map) {
    return SurveyQuestion(
      id: map['id'],
      question: map['question'],
      type: SurveyQuestionType.values
          .firstWhere((e) => e.name == map['type']),
      options: (map['options'] as List? ?? [])
          .map((e) => SurveyOption.fromMap(e))
          .toList(),
      numberRules:
      (map['numberRules'] as List? ?? []).cast<Map<String, int>>(),
      fileWeight: map['fileWeight'] ?? 0,
    );
  }
}
