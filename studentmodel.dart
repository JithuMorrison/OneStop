import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

StudentModel StudentModelFromJson(String str) => StudentModel.fromJson(json.decode(str));

String StudentModelToJson(StudentModel data) => json.encode(data.toJson());

class StudentModel {
  String id;
  String section;
  String dept;
  List<Student> student;

  StudentModel({
    required this.id,
    required this.section,
    required this.dept,
    required this.student,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json["_id"],
    section: json["section"],
    dept: json["dept"],
    student: List<Student>.from(json["student"].map((x) => Student.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "section": section,
    "dept": dept,
    "student": List<dynamic>.from(student.map((x) => x.toJson())),
  };
}

class Student {
  String name;
  String email;
  List<List<dynamic>> attendance;

  Student({
    required this.name,
    required this.email,
    required this.attendance,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    name: json["name"],
    email: json["email"],
    attendance: List<List<dynamic>>.from(json["attendance"].map((x) => List<dynamic>.from(x.map((x) => x)))),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "attendance": List<dynamic>.from(attendance.map((x) => List<dynamic>.from(x.map((x) => x)))),
  };
}
