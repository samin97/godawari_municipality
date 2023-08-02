// To parse this JSON data, do
//
//     final postAnugamanModel = postAnugamanModelFromJson(jsonString);

import 'dart:convert';

PostAnugamanModel postAnugamanModelFromJson(String str) =>
    PostAnugamanModel.fromJson(json.decode(str));

String postAnugamanModelToJson(PostAnugamanModel data) =>
    json.encode(data.toJson());

class PostAnugamanModel {

  int budgetId;
  String? monitoringDateNep;
  String? whatYouSaw;
  String? yourFeedBack;
  String? responseOfPreviousFeedback;
  String? progressStatus;
  String? complitionPercentage;
  String? quality;
  String? remarksOnQuality;
  String? additionalNote;
  String? consultantReprisintive;
  String? reprisintivePhone;
  String? overAllRemarks;
  String? latitude;
  String? longitude;
  int? anugamanTypeId;
  String? image1;
  String? image2;
  String? image3;

  PostAnugamanModel({

    required this.budgetId,
    this.monitoringDateNep,
    this.whatYouSaw,
    this.yourFeedBack,
    this.responseOfPreviousFeedback,
    this.progressStatus,
    this.complitionPercentage,
    this.quality,
    this.remarksOnQuality,
    this.additionalNote,
    this.consultantReprisintive,
    this.reprisintivePhone,
    this.overAllRemarks,
    this.latitude,
    this.longitude,
    this.anugamanTypeId,
    this.image1,
    this.image2,
    this.image3,
  });

  factory PostAnugamanModel.fromJson(Map<String, dynamic> json) =>
      PostAnugamanModel(
        budgetId: json["BudgetId"],
        monitoringDateNep: json["MonitoringDateNep"],
        whatYouSaw: json["WhatYouSaw"],
        yourFeedBack: json["YourFeedBack"],
        responseOfPreviousFeedback: json["ResponseOfPreviousFeedback"],
        progressStatus: json["ProgressStatus"],
        complitionPercentage: json["ComplitionPercentage"],
        quality: json["Quality"],
        remarksOnQuality: json["RemarksOnQuality"],
        additionalNote: json["AdditionalNote"],
        consultantReprisintive: json["ConsultantReprisintive"],
        reprisintivePhone: json["ReprisintivePhone"],
        overAllRemarks: json["OverAllRemarks"],
        latitude: json["Latitude"],
        longitude: json["Longitude"],
        anugamanTypeId: json["AnugamanTypeId"],
        image1: json["Image1"],
        image2: json["Image2"],
        image3: json["Image3"],
      );

  Map<String, dynamic> toJson() => {

        "BudgetId": budgetId,
        "MonitoringDateNep": monitoringDateNep,
        "WhatYouSaw": whatYouSaw,
        "YourFeedBack": yourFeedBack,
        "ResponseOfPreviousFeedback": responseOfPreviousFeedback,
        "ProgressStatus": progressStatus,
        "ComplitionPercentage": complitionPercentage,
        "Quality": quality,
        "RemarksOnQuality": remarksOnQuality,
        "AdditionalNote": additionalNote,
        "ConsultantReprisintive": consultantReprisintive,
        "ReprisintivePhone": reprisintivePhone,
        "OverAllRemarks": overAllRemarks,
        "Latitude": latitude,
        "Longitude": longitude,
        "AnugamanTypeId": anugamanTypeId,
        "Image1": image1,
        "Image2": image2,
        "Image3": image3,
      };
}
