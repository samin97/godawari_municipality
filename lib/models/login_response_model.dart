import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) => LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) => json.encode(data.toJson());

class LoginResponseModel {
  LoginResponseModel({
    required this.tokenString,
    required this.username,
    required this.firstName,
    required this.role,
    this.permission,
  });

  String tokenString;
  String username;
  String firstName;
  String role;
  dynamic permission;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
    tokenString: json["tokenString"],
    username: json["username"],
    firstName: json["firstName"],
    role: json["role"],
    permission: json["permission"],
  );

  Map<String, dynamic> toJson() => {
    "tokenString": tokenString,
    "username": username,
    "firstName": firstName,
    "role": role,
    "permission": permission,
  };
}
