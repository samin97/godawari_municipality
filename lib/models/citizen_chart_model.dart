// To parse this JSON data, do
//
//     final citizenChart = citizenChartFromJson(jsonString);

import 'dart:convert';

CitizenChartModel citizenChartModelFromJson(String str) =>
    CitizenChartModel.fromJson(json.decode(str));

String citizenChartModelToJson(CitizenChartModel data) => json.encode(data.toJson());

class CitizenChartModel {
  String? sakhaName;
  String? sewaCategory;
  String? sewaKisim;
  int? sewaSulkhaRs;
  String? lagneSamaya;
  String? jimbebarAdhakari;
  String? gunashoKoAdhakari;
  String? remarks;
  String? awasekKagajat;
  String? userCreated;

  CitizenChartModel({
    this.sakhaName,
    this.sewaCategory,
    this.sewaKisim,
    this.sewaSulkhaRs,
    this.lagneSamaya,
    this.jimbebarAdhakari,
    this.gunashoKoAdhakari,
    this.remarks,
    this.awasekKagajat,
    this.userCreated,
  });

  factory CitizenChartModel.fromJson(Map<String, dynamic> json) => CitizenChartModel(
        sakhaName: json["sakhaName"],
        sewaCategory: json["sewaCategory"],
        sewaKisim: json["sewaKisim"],
        sewaSulkhaRs: json["sewaSulkhaRs"],
        lagneSamaya: json["lagneSamaya"],
        jimbebarAdhakari: json["jimbebarAdhakari"],
        gunashoKoAdhakari: json["gunashoKoAdhakari"],
        remarks: json["remarks"],
        awasekKagajat: json["awasekKagajat"],
        userCreated: json["userCreated"],
      );

  Map<String, dynamic> toJson() => {
        "sakhaName": sakhaName,
        "sewaCategory": sewaCategory,
        "sewaKisim": sewaKisim,
        "sewaSulkhaRs": sewaSulkhaRs,
        "lagneSamaya": lagneSamaya,
        "jimbebarAdhakari": jimbebarAdhakari,
        "gunashoKoAdhakari": gunashoKoAdhakari,
        "remarks": remarks,
        "awasekKagajat": awasekKagajat,
        "userCreated": userCreated,
      };
}
