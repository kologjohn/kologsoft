class stockingModeModel {
  String name;
  String staff;
  String id;
  DateTime date;
  String companyid;
  String company;

  stockingModeModel({
    required this.name,
    required this.staff,
    required this.id,
    required this.date,
    required this.companyid,
    required this.company,
  });


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
      'staff': staff,
      'date': date.toIso8601String(),
      'created_at': DateTime.now(),
      'companyid': companyid,
      'company': company,
    };
  }
}