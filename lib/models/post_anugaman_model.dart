import 'dart:convert';

PostAnugamanModel postAnugamanModelFromJson(String str) =>
    PostAnugamanModel.fromJson(json.decode(str));

String postAnugamanModelToJson(PostAnugamanModel data) =>
    json.encode(data.toJson());

class PostAnugamanModel {
  int? budgetId;
  String? monitoringDateNep;
  List<String>? whatYouSawList;
  String? whatYouSaw;
  String? yourFeedBack;
  String? progressStatus;
  String? complitionPercentage;
  String? responseOfPreviousFeedback;
  String? reprisintivePhone;
  String? image1;
  String? image2;
  String? image3;
  String? quality;
  String? remarksOnQuality;
  String? additionalNote;
  String? consultantReprisintive;
  String? overAllRemarks;
  String? latitude;
  String? longitude;
  bool? isGroup;
  List<UserAssigned> userAssigneds;

  PostAnugamanModel({
    this.budgetId,
    this.monitoringDateNep,
    this.whatYouSawList,
    this.whatYouSaw,
    this.yourFeedBack,
    this.responseOfPreviousFeedback,
    this.progressStatus,
    this.complitionPercentage,
    this.reprisintivePhone,
    this.image1,
    this.image2,
    this.image3,
    this.quality,
    this.remarksOnQuality,
    this.additionalNote,
    this.consultantReprisintive,
    this.overAllRemarks,
    this.latitude,
    this.longitude,
    this.isGroup,
    required this.userAssigneds,
  });

  factory PostAnugamanModel.fromJson(Map<String, dynamic> json) =>
      PostAnugamanModel(
        budgetId: json["budgetId"],
        monitoringDateNep: json["monitoringDateNep"],
        whatYouSawList: List<String>.from(json["whatYouSawList"].map((x) => x)),
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
        isGroup: json["isGroup"],
        userAssigneds: List<UserAssigned>.from(
            json["userAssigneds"].map((x) => UserAssigned.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "budgetId": budgetId,
    "monitoringDateNep": monitoringDateNep,
    "whatYouSawList": List<dynamic>.from(whatYouSawList!.map((x) => x)),
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
    "isGroup": isGroup,
    "userAssigneds":
    List<dynamic>.from(userAssigneds.map((x) => x.toJson())),
  };
}

class UserAssigned {
  String? id;
  bool? isAssigned;

  UserAssigned({
    this.id,
    this.isAssigned,
  });

  factory UserAssigned.fromJson(Map<String, dynamic> json) => UserAssigned(
    id: json["id"],
    isAssigned: json["isAssigned"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "isAssigned": isAssigned,
  };
}
