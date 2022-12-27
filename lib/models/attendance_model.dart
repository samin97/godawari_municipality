import 'dart:convert';

AttendanceModel attendanceModelFromJson(String str) => AttendanceModel.fromJson(json.decode(str));

String attendanceModelToJson(AttendanceModel data) => json.encode(data.toJson());

class AttendanceModel {
  AttendanceModel({
    required this.nepaliDate,
    required this.englishDate,
    required this.attendDateTime,
    required this.latitude,
    required this.longitude,
    required this.deviceId,
    this.networkId,
    this.altitude,
    required this.status,
    required this.mobileNo,
  });

  String? nepaliDate;
  String? englishDate;
  String attendDateTime;
  String? latitude;
  String? longitude;
  String deviceId;
  String? networkId;
  String? altitude;
  String? status;
  String? mobileNo;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) => AttendanceModel(
    nepaliDate: json["nepaliDate"],
    englishDate: json["englishDate"],
    attendDateTime: json["attendDateTime"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    deviceId: json["deviceId"],
    networkId: json["networkId"],
    altitude: json["altitude"],
    status: json["status"],
    mobileNo: json["mobileNo"],
  );

  Map<String, dynamic> toJson() => {
    "nepaliDate": nepaliDate,
    "englishDate": englishDate,
    "attendDateTime": attendDateTime,
    "latitude": latitude,
    "longitude": longitude,
    "deviceId": deviceId,
    "networkId": networkId,
    "altitude": altitude,
    "status": status,
    "mobileNo": mobileNo,
  };
}
