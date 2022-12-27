import 'dart:convert';

LeaveModel leaveModelFromJson(String str) =>
    LeaveModel.fromJson(json.decode(str));

String leaveModelToJson(LeaveModel data) => json.encode(data.toJson());

class LeaveModel {
  LeaveModel(
      {this.id,
      this.userName,
      this.leaveFor,
      this.leaveDate,
      this.leaveTo,
      this.description,
      this.status,
      this.requestedBy,
      this.signatureImagePath,
      this.signature});

  int? id;
  String? userName;
  String? leaveFor;
  String? leaveDate;
  String? leaveTo;
  String? description;
  String? status;
  String? requestedBy;
  String? signatureImagePath;
  String? signature;

  factory LeaveModel.fromJson(Map<String, dynamic> json) => LeaveModel(
        id: json["id"],
        userName: json["userName"],
        leaveFor: json["leaveFor"],
        leaveDate: json["leaveDate"],
        leaveTo: json["leaveTo"],
        description: json["description"],
        status: json["status"],
        requestedBy: json["requestedBy"],
        signatureImagePath: json["signatureImagePath"],
        signature: json["signature"],
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
        "signature": signature
      };
}
