// To parse this JSON data, do
//
//     final registrationModel = registrationModelFromJson(jsonString);

import 'dart:convert';

RegistrationModel registrationModelFromJson(String str) => RegistrationModel.fromJson(json.decode(str));

String registrationModelToJson(RegistrationModel data) => json.encode(data.toJson());

class RegistrationModel {
  String? firstName;
  String? employeeId;
  String? dob;
  String? email;
  String? phoneNo;
  String? province;
  String? district;
  String? localLevel;
  String? wardNo;
  String? rastyaParichayaPatraNo;
  String? nagariktaNo;
  String? password;

  RegistrationModel({
     this.firstName,
     this.employeeId,
     this.dob,
     this.email,
     this.phoneNo,
     this.province,
     this.district,
     this.localLevel,
     this.wardNo,
     this.rastyaParichayaPatraNo,
     this.nagariktaNo,
     this.password,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) => RegistrationModel(
    firstName: json["firstName"],
    employeeId: json["employeeId"],
    dob: json["dob"],
    email: json["email"],
    phoneNo: json["phoneNo"],
    province: json["province"],
    district: json["district"],
    localLevel: json["localLevel"],
    wardNo: json["wardNo"],
    rastyaParichayaPatraNo: json["rastyaParichayaPatraNo"],
    nagariktaNo: json["nagariktaNO"],
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "employeeId": employeeId,
    "dob": dob,
    "email": email,
    "phoneNo": phoneNo,
    "province": province,
    "district": district,
    "localLevel": localLevel,
    "wardNo": wardNo,
    "rastyaParichayaPatraNo": rastyaParichayaPatraNo,
    "nagariktaNO": nagariktaNo,
    "password": password,
  };
}
