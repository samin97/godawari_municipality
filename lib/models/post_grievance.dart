// To parse this JSON data, do
//
//     final postGrievance = postGrievanceFromJson(jsonString);

import 'dart:convert';

PostGrievance postGrievanceFromJson(String str) => PostGrievance.fromJson(json.decode(str));

String postGrievanceToJson(PostGrievance data) => json.encode(data.toJson());

class PostGrievance {
  String id;
  String name;
  String subject;
  String grievance;

  PostGrievance({
    required this.id,
    required this.name,
    required this.subject,
    required this.grievance,
  });

  factory PostGrievance.fromJson(Map<String, dynamic> json) => PostGrievance(
    id: json["id"],
    name: json["name"],
    subject: json["subject"],
    grievance: json["grievance"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "subject": subject,
    "grievance": grievance,
  };
}
