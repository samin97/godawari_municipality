import 'dart:convert';

MonthlyReportModel monthlyReportFromJson(String str) =>
    MonthlyReportModel.fromJson(json.decode(str));

String monthlyReportToJson(MonthlyReportModel data) => json.encode(data.toJson());

class MonthlyReportModel {
  MonthlyReportModel({
     this.name,
     this.checkInTime,
     this.checkOutTime,
     this.workingHour,
     this.remarks,
     this.date,
  });

  String? name;
  String? checkInTime;
  String? checkOutTime;
  String? workingHour;
  String? remarks;
  String? date;

  factory MonthlyReportModel.fromJson(Map<String, dynamic> json) => MonthlyReportModel(
        name: json["name"],
        checkInTime: json["checkInTime"],
        checkOutTime: json["checkOutTime"],
        workingHour: json["workingHour"],
        remarks: json["remarks"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "checkInTime": checkInTime,
        "checkOutTime": checkOutTime,
        "workingHour": workingHour,
        "remarks": remarks,
        "date": date,
      };
}
