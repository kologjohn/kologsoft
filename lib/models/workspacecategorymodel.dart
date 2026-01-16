class WorkspaceCategoryModel {
  final String name;
  final String workspaceclass;
  final String staff;
  final String id;
  final DateTime date;

  WorkspaceCategoryModel({
    required this.name,
    required this.workspaceclass,
    required this.staff,
    required this.id,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'workspaceClass': workspaceclass,
      'staff': staff,
      'id': id,
      'date': date.toIso8601String(),
      'createdAt': DateTime.now(),
    };
  }

  // Factory constructor to create a WorkspaceCategoryModel from Firestore document
  factory WorkspaceCategoryModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return WorkspaceCategoryModel(
      name: map['name'] ?? '',
      workspaceclass: map['workspaceClass'] ?? '',
      staff: map['staff'] ?? '',
      id: docId,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }
}
