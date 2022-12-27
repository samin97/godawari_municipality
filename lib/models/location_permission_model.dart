import 'dart:convert';

LocationModel locationModelFromJson(String str) => LocationModel.fromJson(json.decode(str));

String locationModelToJson(LocationModel data) => json.encode(data.toJson());

class LocationModel {
  LocationModel({
    this.id,
    this.latitude,
    this.longitude,
    this.meters,
  });

  int? id;
  String? latitude;
  String? longitude;
  String? meters;

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    id: json["id"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    meters: json["meters"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "latitude": latitude,
    "longitude": longitude,
    "meters": meters,
  };
}
