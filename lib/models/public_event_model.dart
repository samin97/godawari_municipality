// To parse this JSON data, do
//
//     final publicEventModel = publicEventModelFromJson(jsonString);

import 'dart:convert';

PublicEventModel publicEventModelFromJson(String str) =>
    PublicEventModel.fromJson(json.decode(str));

String publicEventModelToJson(PublicEventModel data) =>
    json.encode(data.toJson());

class PublicEventModel {
  String? name;
  String? shortDescription;
  String? longDescription;
  String? startDate;
  String? endDate;
  String? photo;

  PublicEventModel({
    this.name,
    this.shortDescription,
    this.longDescription,
    this.startDate,
    this.endDate,
    this.photo,
  });

  factory PublicEventModel.fromJson(Map<String, dynamic> json) =>
      PublicEventModel(
        name: json["name"],
        shortDescription: json["shortDescription"],
        longDescription: json["longDescription"],
        startDate: json["startDate"],
        endDate: json["endDate"],
        photo: json["photo"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "shortDescription": shortDescription,
        "longDescription": longDescription,
        "startDate": startDate,
        "endDate": endDate,
        "photo": photo,
      };
}
