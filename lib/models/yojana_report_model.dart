// To parse this JSON data, do
//
//     final yojanaReportModel = yojanaReportModelFromJson(jsonString);

import 'dart:convert';

YojanaReportModel yojanaReportModelFromJson(String str) => YojanaReportModel.fromJson(json.decode(str));

String yojanaReportModelToJson(YojanaReportModel data) => json.encode(data.toJson());

class YojanaReportModel {
  int? id;
  int? budgetId;
  String? monitoringDate;
  String? monitoringDateNep;
  String? monitoringTime;
  String? whatYouSaw;
  String? yourFeedBack;
  String? responseOfPreviousFeedback;
  String? progressStatus;
  String? complitionPercentage;
  String? image1;
  String? image2;
  String? image3;
  String? quality;
  String? remarksOnQuality;
  String? additionalNote;
  String? consultantReprisintive;
  String? reprisintivePhone;
  String? overAllRemarks;
  String? latitude;
  String? longitude;
  int? anugamanTypeId;

  YojanaReportModel({
     this.id,
     this.budgetId,
     this.monitoringDate,
     this.monitoringDateNep,
     this.monitoringTime,
     this.whatYouSaw,
     this.yourFeedBack,
     this.responseOfPreviousFeedback,
     this.progressStatus,
     this.complitionPercentage,
     this.image1,
     this.image2,
     this.image3,
     this.quality,
     this.remarksOnQuality,
     this.additionalNote,
     this.consultantReprisintive,
     this.reprisintivePhone,
     this.overAllRemarks,
     this.latitude,
     this.longitude,
     this.anugamanTypeId,
  });

  factory YojanaReportModel.fromJson(Map<String, dynamic> json) => YojanaReportModel(
    id: json["id"],
    budgetId: json["budgetId"],
    monitoringDate: json["monitoringDate"],
    monitoringDateNep: json["monitoringDateNep"],
    monitoringTime: json["monitoringTime"],
    whatYouSaw: json["whatYouSaw"],
    yourFeedBack: json["yourFeedBack"],
    responseOfPreviousFeedback: json["responseOfPreviousFeedback"],
    progressStatus: json["progressStatus"],
    complitionPercentage: json["complitionPercentage"],
    image1: json["image1"],
    image2: json["image2"],
    image3: json["image3"],
    quality: json["quality"],
    remarksOnQuality: json["remarksOnQuality"],
    additionalNote: json["additionalNote"],
    consultantReprisintive: json["consultantReprisintive"],
    reprisintivePhone: json["reprisintivePhone"],
    overAllRemarks: json["overAllRemarks"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    anugamanTypeId: json["anugamanTypeId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "budgetId": budgetId,
    "monitoringDate": monitoringDate,
    "monitoringDateNep": monitoringDateNep,
    "monitoringTime": monitoringTime,
    "whatYouSaw": whatYouSaw,
    "yourFeedBack": yourFeedBack,
    "responseOfPreviousFeedback": responseOfPreviousFeedback,
    "progressStatus": progressStatus,
    "complitionPercentage": complitionPercentage,
    "image1": image1,
    "image2": image2,
    "image3": image3,
    "quality": quality,
    "remarksOnQuality": remarksOnQuality,
    "additionalNote": additionalNote,
    "consultantReprisintive": consultantReprisintive,
    "reprisintivePhone": reprisintivePhone,
    "overAllRemarks": overAllRemarks,
    "latitude": latitude,
    "longitude": longitude,
    "anugamanTypeId": anugamanTypeId,
  };
}
