import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String name;
  final String userStaff;
  final String userEmail;
  final Timestamp date;

  Category({
    required this.name,
    required this.userStaff,
    required this.userEmail,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'userStaff': userStaff,
    'userEmail': userEmail,
    'date': date,
  };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    name: map['name'] ?? '',
    userStaff: map['userStaff'] ?? '',
    userEmail: map['userEmail'] ?? '',
    date: map['date'] ?? Timestamp.now(),
  );
}
