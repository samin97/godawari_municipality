import 'dart:convert';

WorkCheckTime workCheckTimeFromJson(String str) =>
    WorkCheckTime.fromJson(json.decode(str));

String workCheckTimeToJson(WorkCheckTime data) => json.encode(data.toJson());

class WorkCheckTime {
  WorkCheckTime({
    required this.upasthitHunaPauneSamaya,
    required this.upasthitHunaPauneSamayaSimaAaanyaDin,
    required this.upasthitHunaPauneSamayaSImaFriday,
  });

  String upasthitHunaPauneSamaya;
  String upasthitHunaPauneSamayaSimaAaanyaDin;
  String upasthitHunaPauneSamayaSImaFriday;

  factory WorkCheckTime.fromJson(Map<String, dynamic> json) => WorkCheckTime(
        upasthitHunaPauneSamaya: json["upasthitHunaPauneSamaya"],
        upasthitHunaPauneSamayaSimaAaanyaDin:
            json["upasthitHunaPauneSamayaSimaAaanyaDin"],
        upasthitHunaPauneSamayaSImaFriday:
            json["upasthitHunaPauneSamayaSImaFriday"],
      );

  Map<String, dynamic> toJson() => {
        "upasthitHunaPauneSamaya": upasthitHunaPauneSamaya,
        "upasthitHunaPauneSamayaSimaAaanyaDin":
            upasthitHunaPauneSamayaSimaAaanyaDin,
        "upasthitHunaPauneSamayaSImaFriday": upasthitHunaPauneSamayaSImaFriday,
      };
}
