import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) =>
    LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) =>
    json.encode(data.toJson());

class LoginResponseModel {
  LoginResponseModel({
    required this.tokenString,
    required this.username,
    this.firstName,
    this.role,
    this.nepaliName,
    required this.latitude,
    required this.longitude,
    this.deviceId,
    this.meters,
    this.permission,
  });

  String? tokenString;
  String? username;
  String? firstName;
  String? role;
  dynamic nepaliName;
  String? latitude;
  String? longitude;
  dynamic deviceId;
  dynamic meters;
  dynamic permission;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        tokenString: json["tokenString"],
        username: json["username"],
        firstName: json["firstName"],
        role: json["role"],
        permission: json["permission"],
        nepaliName: json["nepaliName"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        deviceId: json["deviceId"],
        meters: json["meters"],
      );

  Map<String, dynamic> toJson() => {
        "tokenString": tokenString,
        "username": username,
        "firstName": firstName,
        "role": role,
        "permission": permission,
        "nepaliName": nepaliName,
        "latitude": latitude,
        "longitude": longitude,
        "deviceId": deviceId,
        "meters": meters,
      };
}
