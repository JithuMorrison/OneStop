import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

MongoDbModel mongoDbModelFromJson(String str) => MongoDbModel.fromJson(json.decode(str));

String mongoDbModelToJson(MongoDbModel data) => json.encode(data.toJson());

class MongoDbModel {
  ObjectId id;
  String username;
  String name;
  String email;
  String phoneNumber;
  String role;
  String dob;
  String dept;
  String section;
  String year;
  int credit;
  List<String> favblog;
  List<String> favmat;
  List<String> titles;
  List<Event> events;

  MongoDbModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.dob,
    required this.dept,
    required this.section,
    required this.year,
    required this.credit,
    required this.favblog,
    required this.favmat,
    required this.titles,
    required this.events,
  });

  factory MongoDbModel.fromJson(Map<String, dynamic> json) => MongoDbModel(
    id: json["_id"],
    username: json["username"],
    name: json["name"],
    email: json["email"],
    phoneNumber: json["phone_number"],
    role: json["role"],
    dob: json["dob"],
    dept: json["dept"],
    section: json["section"],
    year: json["year"],
    credit: json["credit"],
    favblog: List<String>.from(json["favblog"].map((x) => x)),
    favmat: List<String>.from(json["favmat"].map((x) => x)),
    titles: List<String>.from(json["titles"].map((x) => x)),
    events: List<Event>.from(json["events"].map((x) => Event.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "username": username,
    "name": name,
    "email": email,
    "phone_number": phoneNumber,
    "role": role,
    "dob": dob,
    "dept": dept,
    "section": section,
    "year": year,
    "credit": credit,
    "favblog": List<dynamic>.from(favblog.map((x) => x)),
    "favmat": List<dynamic>.from(favmat.map((x) => x)),
    "titles": List<dynamic>.from(titles.map((x) => x)),
    "events": List<dynamic>.from(events.map((x) => x.toJson())),
  };
}

class Event {
  DateTime date;
  List<Detail> details;

  Event({
    required this.date,
    required this.details,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    date: DateTime.parse(json["date"]),
    details: List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "details": List<dynamic>.from(details.map((x) => x.toJson())),
  };
}

class Detail {
  String title;
  String type;

  Detail({
    required this.title,
    required this.type,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    title: json["title"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "type": type,
  };
}
