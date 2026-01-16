class RevenueModel {
  final String name;
  final String workspaceclass;
  final String staff;
  final String id;
  final DateTime date;

  RevenueModel({
    required this.name,
    required this.workspaceclass,
    required this.staff,
    required this.id,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'workspaceclass': workspaceclass,
      'staff': staff,
      'id': id,
      'date': date.toIso8601String(),
      'createdAt': DateTime.now(),
    };
  }
}