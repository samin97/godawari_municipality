import 'dart:convert';

AdminGetLeaveModel adminGetLeaveModelFromJson(String str) =>
    AdminGetLeaveModel.fromJson(json.decode(str));

String adminGetLeaveModelToJson(AdminGetLeaveModel data) =>
    json.encode(data.toJson());

class AdminGetLeaveModel {
  AdminGetLeaveModel({
    required this.id,
    this.userName,
    this.leaveFor,
    this.leaveDate,
    this.leaveTo,
    this.description,
    required this.status,
    this.requestedBy,
    this.signatureImagePath,
  });

  int id;
  String? userName;
  String? leaveFor;
  String? leaveDate;
  String? leaveTo;
  String? description;
  String? status;
  String? requestedBy;
  String? signatureImagePath;

  factory AdminGetLeaveModel.fromJson(Map<String, dynamic> json) =>
      AdminGetLeaveModel(
        id: json["id"],
        userName: json["userName"],
        leaveFor: json["leaveFor"],
        leaveDate: json["leaveDate"],
        leaveTo: json["leaveTo"],
        description: json["description"],
        status: json["status"],
        requestedBy: json["requestedBy"],
        signatureImagePath: json["signatureImagePath"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userName": userName,
        "leaveFor": leaveFor,
        "leaveDate": leaveDate,
        "leaveTo": leaveTo,
        "description": description,
        "status": status,
        "requestedBy": requestedBy,
        "signatureImagePath": signatureImagePath,
      };
}
