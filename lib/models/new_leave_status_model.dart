import 'dart:convert';

NewStatus newStatusFromJson(String str) => NewStatus.fromJson(json.decode(str));

String newStatusToJson(NewStatus data) => json.encode(data.toJson());

class NewStatus {
  NewStatus({
    required this.id,
    required this.status,
  });

  int id;
  String status;

  factory NewStatus.fromJson(Map<String, dynamic> json) => NewStatus(
        id: json["id"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
      };
}
