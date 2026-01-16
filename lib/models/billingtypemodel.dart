class bilingtypeModel {
  String name;
  String staff;
  String id;
  DateTime date;

  bilingtypeModel({
    required this.name,
    required this.staff,
    required this.id,
    required this.date,
  });


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
      'staff': staff,
      'date': date.toIso8601String(),
      'created_at': DateTime.now(),
    };
  }
}