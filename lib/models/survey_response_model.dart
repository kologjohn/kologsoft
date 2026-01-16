class SurveyResponse {
  final String id;
  final String surveyId;
  final String staffId;
  final int totalScore;
  final DateTime submittedAt;
  final Map<String, dynamic> answers;

  SurveyResponse({
    required this.id,
    required this.surveyId,
    required this.staffId,
    required this.totalScore,
    required this.submittedAt,
    required this.answers,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'surveyId': surveyId,
    'staffId': staffId,
    'totalScore': totalScore,
    'submittedAt': submittedAt,
    'answers': answers,
  };
}
