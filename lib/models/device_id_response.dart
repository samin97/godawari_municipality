import 'dart:convert';

DeviceIdResponse deviceIdResponseFromJson(String str) => DeviceIdResponse.fromJson(json.decode(str));

String deviceIdResponseToJson(DeviceIdResponse data) => json.encode(data.toJson());

class DeviceIdResponse {
  DeviceIdResponse({
    required this.firstName,
    required this.username,
    required this.deviceId,
  });

  String firstName;
  String username;
  String deviceId;

  factory DeviceIdResponse.fromJson(Map<String, dynamic> json) => DeviceIdResponse(
    firstName: json["firstName"],
    username: json["username"],
    deviceId: json["deviceId"],
  );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "username": username,
    "deviceId": deviceId,
  };
}
