import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

AnnouncementModel AnnouncementModelFromJson(String str) => AnnouncementModel.fromJson(json.decode(str));

String AnnouncementModelToJson(AnnouncementModel data) => json.encode(data.toJson());

class AnnouncementModel {
  ObjectId id;
  String title;
  String desc;
  DateTime date;
  String time;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.desc,
    required this.date,
    required this.time,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) => AnnouncementModel(
    id: json["_id"],
    title: json["title"],
    desc: json["desc"],
    date: DateTime.parse(json["date"]),
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "desc": desc,
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "time": time,
  };
}
