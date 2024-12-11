import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

CalendarEventModel CalendarEventModelFromJson(String str) => CalendarEventModel.fromJson(json.decode(str));

String CalendarEventModelToJson(CalendarEventModel data) => json.encode(data.toJson());

class CalendarEventModel {
  ObjectId id;
  String type;
  List<Event> events;

  CalendarEventModel({
    required this.id,
    required this.type,
    required this.events,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) => CalendarEventModel(
    id: json["_id"],
    type: json["type"],
    events: List<Event>.from(json["events"].map((x) => Event.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "type": type,
    "events": List<dynamic>.from(events.map((x) => x.toJson())),
  };
}

class Event {
  String date;
  List<Detail> details;

  Event({
    required this.date,
    required this.details,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    date: json["date"],
    details: List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "details": List<dynamic>.from(details.map((x) => x.toJson())),
  };
}

class Detail {
  String title;

  Detail({
    required this.title,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
  };
}
