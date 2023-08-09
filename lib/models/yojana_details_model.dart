import 'dart:convert';

List<YojanaModel> yojanaModelFromJson(String str) => List<YojanaModel>.from(
    json.decode(str).map((x) => YojanaModel.fromJson(x)));

String yojanaModelToJson(List<YojanaModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class YojanaModel {
  int id;
  String? activityName;
  String? serialNo;
  String? karchaSrishak;
  String? kharchaUpaSirshak;
  String? sanketNo;
  String? sourceOfFund;
  String? budgetBiniyojanType;
  String? planningProgram;
  String? yearlyBudget;

  YojanaModel({
    required this.id,
    this.activityName,
    this.serialNo,
    this.karchaSrishak,
    this.kharchaUpaSirshak,
    this.sanketNo,
    this.sourceOfFund,
    this.budgetBiniyojanType,
    this.planningProgram,
    this.yearlyBudget,
  });

  factory YojanaModel.fromJson(Map<String, dynamic> json) => YojanaModel(
        id: json["id"],
        activityName: json["activityName"],
        serialNo: json["serialNO"],
        karchaSrishak: json["karchaSrishak"],
        kharchaUpaSirshak: json["kharchaUpaSirshak"],
        sanketNo: json["sanketNO"],
        sourceOfFund: json["sourceOfFund"],
        budgetBiniyojanType: json["budgetBiniyojanType"],
        planningProgram: json["planningProgram"],
        yearlyBudget: json["yearly"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "activityName": activityName,
        "serialNO": serialNo,
        "karchaSrishak": karchaSrishak,
        "kharchaUpaSirshak": kharchaUpaSirshak,
        "sanketNO": sanketNo,
        "sourceOfFund": sourceOfFund,
        "budgetBiniyojanType": budgetBiniyojanType,
        "planningProgram": planningProgram,
        "yearly": yearlyBudget,
      };
}
