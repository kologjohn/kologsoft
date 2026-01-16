class WorkspaceModel {
  String name;
  String staff;
  String id;
  DateTime date;

  WorkspaceModel({
    required this.name,
    required this.staff,
    required this.id,
    required this.date,
  });

  // Convert to Map for Database (Firestore/SQL)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'staff': staff,
      'id': id,
      'date': date.toIso8601String(),
      'created_at': DateTime.now(),
    };
  }
}