import 'dart:convert';

StudentModel StudentModelFromJson(String str) => StudentModel.fromJson(json.decode(str));

String StudentModelToJson(StudentModel data) => json.encode(data.toJson());

class StudentModel {
  String section;
  String dept;
  String year;
  List<Student> students;

  StudentModel({
    required this.section,
    required this.dept,
    required this.year,
    required this.students,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    section: json["section"],
    dept: json["dept"],
    year: json["year"],
    students: List<Student>.from(json["students"].map((x) => Student.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "section": section,
    "dept": dept,
    "year": year,
    "students": List<dynamic>.from(students.map((x) => x.toJson())),
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
