import 'dart:convert';

AdminGetKaajModel adminGetLeaveModelFromJson(String str) =>
    AdminGetKaajModel.fromJson(json.decode(str));

String adminGetLeaveModelToJson(AdminGetKaajModel data) =>
    json.encode(data.toJson());

class AdminGetKaajModel {
  AdminGetKaajModel({
    required this.id,
    this.placeForVisit,
    this.bhramanStartDate,
    this.bhramanEndDate,
    this.peskiRakam,
    this.description,
    required this.status,
    this.panurodhPatraPath,
    this.pratibhadahnPath,
  });

  int id;
  String? placeForVisit;
  String? bhramanStartDate;
  String? bhramanEndDate;
  String? peskiRakam;
  String? description;
  String? status;
  String? panurodhPatraPath;
  String? pratibhadahnPath;

  factory AdminGetKaajModel.fromJson(Map<String, dynamic> json) =>
      AdminGetKaajModel(
        id: json["id"],
        placeForVisit: json["placeForVisit"],
        bhramanStartDate: json["bhramanStartDate"],
        bhramanEndDate: json["bhramanEndDate"],
        peskiRakam: json["peskiRakam"],
        description: json["description"],
        status: json["status"],
        panurodhPatraPath: json["panurodhPatraPath"],
        pratibhadahnPath: json["pratibhadahnPath"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "placeForVisit": placeForVisit,
        "bhramanStartDate": bhramanStartDate,
        "bhramanEndDate": bhramanEndDate,
        "peskiRakam": peskiRakam,
        "description": description,
        "status": status,
        "panurodhPatraPath": panurodhPatraPath,
        "pratibhadahnPath": pratibhadahnPath,
      };
}
