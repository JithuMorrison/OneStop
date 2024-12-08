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
  int credit;
  List<Event> events;

  MongoDbModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.dob,
    required this.credit,
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
    credit: json["credit"],
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
    "credit": credit,
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
