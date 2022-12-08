import 'dart:convert';

EventModel eventModelFromJson(String str) => EventModel.fromJson(json.decode(str));

String eventModelToJson(EventModel data) => json.encode(data.toJson());

class EventModel {
  EventModel({
    this.id,
    this.name,
    this.shortDescription,
    this.longDescription,
    this.photo,
  });

  String? id;
  String? name;
  String? shortDescription;
  String? longDescription;
  String? photo;

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    id: json["id"],
    name: json["name"],
    shortDescription: json["shortDescription"],
    longDescription: json["longDescription"],
    photo: json["photo"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "shortDescription": shortDescription,
    "longDescription": longDescription,
    "photo": photo,
  };
}