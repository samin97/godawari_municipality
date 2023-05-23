// To parse this JSON data, do
//
//     final complainModel = complainModelFromJson(jsonString);

import 'dart:convert';

ComplainModel complainModelFromJson(String str) => ComplainModel.fromJson(json.decode(str));

String complainModelToJson(ComplainModel data) => json.encode(data.toJson());

class ComplainModel {
  String pathaunekoName;
  String phoneNo;
  String email;
  String gunasoKoBisaya;
  String gunasoKoBibaran;

  ComplainModel({
    required this.pathaunekoName,
    required this.phoneNo,
    required this.email,
    required this.gunasoKoBisaya,
    required this.gunasoKoBibaran,
  });

  factory ComplainModel.fromJson(Map<String, dynamic> json) => ComplainModel(
    pathaunekoName: json["pathaunekoName"],
    phoneNo: json["phoneNo"],
    email: json["email"],
    gunasoKoBisaya: json["gunasoKoBisaya"],
    gunasoKoBibaran: json["gunasoKoBibaran"],
  );

  Map<String, dynamic> toJson() => {
    "pathaunekoName": pathaunekoName,
    "phoneNo": phoneNo,
    "email": email,
    "gunasoKoBisaya": gunasoKoBisaya,
    "gunasoKoBibaran": gunasoKoBibaran,
  };
}
