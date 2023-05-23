// To parse this JSON data, do
//
//     final publicEventModel = publicEventModelFromJson(jsonString);

import 'dart:convert';

PublicEventModel publicEventModelFromJson(String str) => PublicEventModel.fromJson(json.decode(str));

String publicEventModelToJson(PublicEventModel data) => json.encode(data.toJson());

class PublicEventModel {
  int? id;
  String? name;
  String? shortDescription;
  String? longDescription;
  String? photo;

  PublicEventModel({
     this.id,
     this.name,
     this.shortDescription,
     this.longDescription,
     this.photo,
  });

  factory PublicEventModel.fromJson(Map<String, dynamic> json) => PublicEventModel(
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
