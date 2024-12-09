import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

CGPAModel CGPAModelFromJson(String str) => CGPAModel.fromJson(json.decode(str));

String CGPAModelToJson(CGPAModel data) => json.encode(data.toJson());

class CGPAModel {
  ObjectId id;
  String dept;
  String sem;
  List<List<dynamic>> subjects;

  CGPAModel({
    required this.id,
    required this.dept,
    required this.sem,
    required this.subjects,
  });

  factory CGPAModel.fromJson(Map<String, dynamic> json) => CGPAModel(
    id: json["_id"],
    dept: json["dept"],
    sem: json["sem"],
    subjects: List<List<dynamic>>.from(json["subjects"].map((x) => List<dynamic>.from(x.map((x) => x)))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "dept": dept,
    "sem": sem,
    "subjects": List<dynamic>.from(subjects.map((x) => List<dynamic>.from(x.map((x) => x)))),
  };
}
